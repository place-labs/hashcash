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
    end
  end

  # test valid? class method
  it "should check if a stamp is valid - not expired, for the right resource and has enough 0 bits" do
    hashcash = Hashcash::Stamp.parse("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    validity = hashcash.valid?("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30))
    validity.should eq true

    invalid_stamp = hashcash.valid?("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "goodbye")
    invalid_stamp.should eq false

    invalid_stamp2 = hashcash.valid?("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2016, 2, 15, 10, 20, 30)..Time.utc(2017, 2, 15, 10, 20, 30))
    invalid_stamp2.should eq false
  end

  # test verify method
  it "should raise error for invalid stamps, otherwise return nil" do
    validity = Hashcash::Stamp.verify!("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30))
    validity.should eq nil

    begin
      invalid = Hashcash::Stamp.verify!("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2018, 2, 15, 10, 20, 30)..Time.utc(2019, 2, 15, 10, 20, 30))
    rescue e
      e.message.should eq "Stamp is expired/not yet valid"
    end

    begin
      invalid = Hashcash::Stamp.verify!("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "goodbye")
    rescue e
      e.message.should eq "Stamp is not valid for the given resource(s)."
    end
  end

  # test high level verify method
  it "should verify if a string is a valid hashcash stamp" do
    verified = Hashcash.verify?("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2021, 12, 7, 23, 22, 33))
    verified.should eq true

    unverified = Hashcash.verify?("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2019, 12, 7, 23, 22, 33))
    unverified.should eq false
  end

  # test is_for?
  it "should check if the correct resource is in the stamp" do
    parsed_string = Hashcash::Stamp.parse("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==")
    parsed_string.is_for?("resource").should eq true
    parsed_string.is_for?("not the resource").should eq false
  end

  # test expired?
  it "should check if a stamp is expired" do
    parsed_string = Hashcash::Stamp.parse("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    parsed_string.expired?(Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2021, 12, 7, 23, 22, 33)).should eq false
    parsed_string.expired?(Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2019, 12, 7, 23, 22, 33)).should eq true

    parsed_string2 = Hashcash::Stamp.parse("1:20:201107232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    parsed_string2.expired?.should eq true

    time = Time.utc.to_s("%y%m%d%H%M%S")
    parsed_string3 = Hashcash::Stamp.parse("1:20:#{time}:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    parsed_string.expired?.should eq false
  end

  # test valid?
  it "should check if a stamp has the correct number of 0 bits" do
    parsed_string = Hashcash::Stamp.parse("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n")
    parsed_string.correct_bits?(20).should eq true
    parsed_string.correct_bits?(22).should eq false

    invalid_stamp = Hashcash::Stamp.parse("1:19:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz")
    invalid_stamp.correct_bits?(20).should eq false

    # custom bits
    parsed_stamp2 = Hashcash::Stamp.parse("1:12:201208004954:hello::RcS+gR0JfNwRv92D:NTczODA3\n")
    parsed_stamp2.correct_bits?(12).should eq true
    parsed_stamp2.correct_bits?.should eq true
    parsed_stamp2.correct_bits?(30).should eq false
  end
end
