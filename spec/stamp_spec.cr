require "./spec_helper"

describe Hashcash::Stamp do
  it ".new" do
    # with just resource arg
    new_stamp = Hashcash::Stamp.new("gab@place.technology")

    new_stamp.resource.should eq "gab@place.technology"
    new_stamp.bits.should eq 20
    new_stamp.date.hour.should eq Time.utc.hour
    new_stamp.version.should eq 1
    new_stamp.counter.should be_a Int32
    new_stamp.rand.should be_a String

    # with all of the args
    custom_stamp = Hashcash::Stamp.new("hi@hello.com", 2, 16, Time.utc, "goodbye")

    custom_stamp.resource.should eq "hi@hello.com"
    custom_stamp.version.should eq 2
    custom_stamp.bits.should eq 16
    custom_stamp.date.hour.should eq Time.utc.hour
  end

  it "#to_s" do
    new_stamp = Hashcash::Stamp.new("gab@place.technology").to_s
    new_stamp.should be_a String
    new_stamp.should start_with "1:20:"
    new_stamp.should contain ":gab@place.technology::"

    custom_stamp = Hashcash::Stamp.new("hi@hello.com", 2, 16, Time.utc(2016, 2, 15, 10, 20, 30), "goodbye").to_s
    custom_stamp.should be_a String
    custom_stamp.should start_with "2:16:160215102030:hi@hello.com:goodbye:"
  end

  it "#update_counter" do
    new_stamp = Hashcash::Stamp.new("hello")
    new_stamp.counter.should eq 0
    # when counter is 0, string should end with 0 base64 encoded (MA==)
    new_stamp.to_s.should end_with ":MA=="
    # string should be invalid here
    Hashcash.verify?(new_stamp.to_s, "hello").should eq false

    new_stamp.update_counter # this method might be renamed
    new_stamp.counter.should be > 0

    new_stamp_string = new_stamp.to_s
    new_stamp_string.should contain ":hello::"
    new_stamp_string.should start_with "1:20:"

    # string should now be valid
    Hashcash.verify?(new_stamp_string, "hello").should eq true

    # with all of the args
    custom_stamp = Hashcash::Stamp.new("hi@hello.com", 1, 16, Time.utc(2016, 2, 15, 10, 20, 30), "goodbye")
    custom_stamp.counter.should eq 0
    custom_stamp.to_s.should end_with ":MA=="
    Hashcash.verify?(custom_stamp.to_s, "hi@hello.com", Time.utc(2016, 1, 15, 10, 20, 30)..Time.utc(2017, 2, 15, 10, 20, 30), 16).should eq false

    custom_stamp.update_counter
    custom_stamp.counter.should be > 0

    custom_stamp_string = custom_stamp.to_s
    custom_stamp_string.should start_with "1:16:160215102030:hi@hello.com:goodbye:"
    Hashcash.verify?(custom_stamp_string, "hi@hello.com", Time.utc(2016, 1, 15, 10, 20, 30)..Time.utc(2017, 2, 15, 10, 20, 30), 16).should eq true
  end

  it ".parse" do
    parsed_string = Hashcash::Stamp.parse("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==")

    parsed_string.version.should eq 1
    parsed_string.bits.should eq 20
    parsed_string.date.should be_a Time
    parsed_string.resource.should eq "resource"
    parsed_string.ext.should eq ""
    parsed_string.to_s.should eq "1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA=="
    parsed_string.rand.should eq "pOWgc88+uDuefr/o"
    parsed_string.counter.should eq 1317860
  end

  it "should not parse an invalid stamp" do
    begin
      Hashcash::Stamp.parse("invalid_stamp")
    rescue e
      e.should be_a(Exception)
      e.message.should eq "invalid stamp format, should contain 6 colons (:)"
    end

    begin
      Hashcash::Stamp.parse("2:12:160215102030:hello@email.com:bye:invalid_stamp:counter")
    rescue e
      e.message.to_s.should eq "stamp version 2 not supported"
    end
  end

  it "#is_for?" do
    parsed_string = Hashcash::Stamp.parse("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==")
    parsed_string.is_for?("resource").should eq true
    parsed_string.is_for?("not the resource").should eq false
  end

  it "#valid?" do
    parsed_string = Hashcash::Stamp.parse("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    parsed_string.valid?(Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2021, 12, 7, 23, 22, 33)).should eq true
    parsed_string.valid?(Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2019, 12, 7, 23, 22, 33)).should eq false

    parsed_string2 = Hashcash::Stamp.parse("1:20:201107232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    parsed_string2.valid?.should eq false

    time = Time.utc.to_s("%y%m%d%H%M%S")
    parsed_string3 = Hashcash::Stamp.parse("1:20:#{time}:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    parsed_string3.valid?.should eq true
  end

  it "#correct_bits?" do
    parsed_string = Hashcash::Stamp.parse("1:20:210106051438:hello::0Ni8oRBm7K0noD1j:NDEyNTQ5")
    parsed_string.correct_bits?(20).should eq true
    parsed_string.correct_bits?(22).should eq false
    parsed_string.correct_bits?.should eq true

    invalid_stamp = Hashcash::Stamp.parse("1:19:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    invalid_stamp.correct_bits?(20).should eq false

    # custom bits
    parsed_stamp2 = Hashcash::Stamp.parse("1:12:210106054523:hello::gyJzsWmtmKpDiWRP:Nzc1Mw==")
    parsed_stamp2.correct_bits?(12).should eq true
    parsed_stamp2.correct_bits?.should eq true
    parsed_stamp2.correct_bits?(20).should eq false
    parsed_stamp2.correct_bits?(30).should eq false
  end
end
