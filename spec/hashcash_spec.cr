require "./spec_helper"

describe Hashcash do
  # test Hashcash.generate
  pending "should initilaise and generate a hashcash stamp using the high level generate method" do
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

  # test high level verify method
  pending "should verify if a string is a valid hashcash stamp" do
    verified = Hashcash.verify?("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2021, 12, 7, 23, 22, 33))
    verified.should eq true

    unverified = Hashcash.verify?("1:20:201207232233:hello::/AwX0LmTwb3g7nx9:NjAwNDcz\n", "hello", Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2019, 12, 7, 23, 22, 33))
    unverified.should eq false
  end

  # test valid?
  pending "should checking if an stamp is valid" do
  end
end
