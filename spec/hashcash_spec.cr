require "./spec_helper"

describe Hashcash do
  it ".generate" do
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

  it ".verify?" do
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

  it ".verify!" do
    string = "1:20:210106063543:hello::/MD1O8MscgavDI6z:MzkyMjM3Ng=="
    validity = Hashcash.verify!(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30))
    validity.should eq nil

    begin
      invalid = Hashcash.verify!(string, "hello", Time.utc(2018, 2, 15, 10, 20, 30)..Time.utc(2019, 2, 15, 10, 20, 30))
    rescue e
      e.message.should eq "Stamp is expired/not yet valid"
    end

    begin
      invalid = Hashcash.verify!(string, "goodbye")
    rescue e
      e.message.should eq "Stamp is not valid for the given resource(s)."
    end

    begin
      invalid = Hashcash.verify!("1:20:210107002222:hello::4eGAF9pYLrO7AuT8:MA==", "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30))
    rescue e
      e.message.should eq "Invalid stamp, not enough 0 bits"
    end
  end
end
