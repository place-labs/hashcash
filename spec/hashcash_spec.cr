require "./spec_helper"

describe Hashcash do
  it "should initialise a new hashcash instance" do
    # with just resource arg
    new_stamp = Hashcash::Stamp.new("gab@place.technology")

    new_stamp.stamp_string.should eq ""
    new_stamp.resource.should eq "gab@place.technology"
    new_stamp.bits.should eq 20
    new_stamp.date.hour.should eq Time.utc.hour
    new_stamp.version.should eq 1

    # with all of the args
    custom_stamp = Hashcash::Stamp.new("hi@hello.com", 2, 16, Time.utc, "goodbye")

    custom_stamp.stamp_string.should eq ""
    custom_stamp.resource.should eq "hi@hello.com"
    custom_stamp.version.should eq 2
    custom_stamp.bits.should eq 16
    custom_stamp.date.hour.should eq Time.utc.hour
  end

  # test generate class method
  it "should generate a hashcash stamp string" do
    new_stamp = Hashcash::Stamp.new("hello")
    new_stamp_string = new_stamp.generate

    new_stamp_string.should contain "hello"
    new_stamp_string[0].should eq '1'
    new_stamp_string.should contain "1:20:"
    new_stamp.stamp_string.should contain "hello"

    # with all of the args
    custom_stamp = Hashcash::Stamp.new("hi@hello.com", 2, 16, Time.utc(2016, 2, 15, 10, 20, 30), "goodbye")
    custom_stamp_string = custom_stamp.generate

    custom_stamp_string.should contain "2:16:160215102030:hi@hello.com:goodbye:"
  end

  # test Hashcash.generate
  it "should initilaise and generate a hashcash stamp using the high level generate method" do
    # just resource arg
    new_stamp = Hashcash.generate("myemail@email.com") # should => "1:20:201206233107:myemail@email.com::hj8j8uUT+MCI/T06:MzI0OTk5\n"

    new_stamp.should contain "1:20:"
    new_stamp.should contain ":myemail@email.com::"
    new_stamp.should be_a String

    # test using all of the args - test different combinations
    custom_stamp = Hashcash.generate("hello@email.com", bits: 16)
    custom_stamp.should contain "1:16:"
    custom_stamp.should contain ":hello@email.com::"
    custom_stamp.should be_a String

    custom_stamp2 = Hashcash.generate("hello@email.com", version: 2, bits: 12, date: Time.utc(2016, 2, 15, 10, 20, 30), ext: "bye")
    custom_stamp2.should contain "2:12:160215102030:hello@email.com:bye:"
    custom_stamp2.should be_a String

    custom_stamp3 = Hashcash.generate("hello@email.com", date: Time.utc(2016, 2, 15, 10, 20, 30), bits: 12, ext: "bye", version: 2)
    custom_stamp3.should contain "2:12:160215102030:hello@email.com:bye:"
    custom_stamp3.should be_a String
  end

  # test parse class method
  it "should parse a string to a Hashcash::Stamp" do
    parsed_string = Hashcash::Stamp.parse("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==")

    parsed_string.version.should eq 1
    parsed_string.bits.should eq 20
    parsed_string.date.should be_a Time
    parsed_string.resource.should eq "resource"
    parsed_string.ext.should eq ""
    parsed_string.stamp_string.should eq "1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA=="  
  end

  it "does not parse an invalid stamp" do
    begin
      parsed_string = Hashcash::Stamp.parse("invalid_stamp")
    rescue e
      e.should be_a(IndexError)
      # is this the correct error here?
    end
  end

  # test verify class method
  it "should verify a valid hashcash stamp" do
    new_stamp = Hashcash::Stamp.new("gab@place.technology", date: Time.utc)

    new_stamp_string = new_stamp.generate
    verified = new_stamp.verify_stamp(new_stamp_string, "gab@place.technology")
    verified.should eq true

    not_verified = new_stamp.verify_stamp(new_stamp_string, "not the resource")
    not_verified.should eq false

    # invalid_stamp = Hashcash::Stamp.verify_stamp("invalid_stamp")
    # invalid_stamp.should eq false
  end

  it "should not verify an invalid hashcash stamp" do
  end

  # test high level verify method
  it "should verify if a string is a valid hashcash stamp" do
    time = Time.utc.to_s("%y%m%d%H%M%S")
    verified = Hashcash.verify("1:20:#{time}:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource")
    verified.should eq true
    # this is returning false right night
  end
end
