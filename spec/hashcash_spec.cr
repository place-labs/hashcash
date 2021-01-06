require "./spec_helper"

describe Hashcash do
  # test Hashcash.generate
  it "should initilaise and generate a hashcash stamp using the high level generate method" do
    # just resource arg
    new_stamp = Hashcash.generate("myemail@email.com") # should => "1:20:201206233107:myemail@email.com::hj8j8uUT+MCI/T06:MzI0OTk5\n"

    new_stamp.should be_a String
    new_stamp.should contain "1:20:"
    new_stamp.should contain ":myemail@email.com::"

    # test using all of the args - test different combinations
    custom_stamp = Hashcash.generate("hello@email.com", bits: 16)
    custom_stamp.should be_a String
    custom_stamp.should contain "1:16:"
    custom_stamp.should contain ":hello@email.com::"

    custom_stamp2 = Hashcash.generate("hello@email.com", version: 2, bits: 12, date: Time.utc(2016, 2, 15, 10, 20, 30), ext: "bye")
    custom_stamp2.should be_a String
    custom_stamp2.should contain "2:12:160215102030:hello@email.com:bye:"

    custom_stamp3 = Hashcash.generate("hello@email.com", date: Time.utc(2016, 2, 15, 10, 20, 30), bits: 12, ext: "bye", version: 2)
    custom_stamp3.should be_a String
    custom_stamp3.should contain "2:12:160215102030:hello@email.com:bye:"
  end

  # test high level verify? method
  it "should verify if a string is a valid hashcash stamp" do
    string = "1:20:210106063543:hello::/MD1O8MscgavDI6z:MzkyMjM3Ng=="

    verified = Hashcash.verify?(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30))
    verified.should eq true

    unverified = Hashcash.verify?(string, "hello", Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2019, 12, 7, 23, 22, 33))
    unverified.should eq false

    unverified2 = Hashcash.verify?(string, "goodbye")
    unverified2.should eq false

    unverified3 = Hashcash.verify?(string, "hello", Time.utc(2016, 2, 15, 10, 20, 30)..Time.utc(2017, 2, 15, 10, 20, 30))
    unverified3.should eq false

    unverified4 = Hashcash.verify?(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30), 40)
    unverified4.should eq false
  end

  # test verify!
  it "should return appropriate errors for invalid stamp_strings" do
  end

  #   # test verify method
  #   it "should raise error for invalid stamps, otherwise return nil" do
  #     hashcash = Hashcash::Stamp.parse("1:20:210106063543:hello::/MD1O8MscgavDI6z:MzkyMjM3Ng==")

  #     validity = hashcash.valid!("hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30))
  #     validity.should eq nil

  #     begin
  #       invalid = hashcash.valid!("hello", Time.utc(2018, 2, 15, 10, 20, 30)..Time.utc(2019, 2, 15, 10, 20, 30))
  #     rescue e
  #       e.message.should eq "Stamp is expired/not yet valid"
  #     end

  #     begin
  #       invalid = hashcash.valid!("goodbye")
  #     rescue e
  #       e.message.should eq "Stamp is not valid for the given resource(s)."
  #     end
  #   end
end
