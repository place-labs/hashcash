require "./spec_helper"

describe Hashcash do
  it ".generate" do
    # just resource arg
    new_stamp = Hashcash.generate("myemail@email.com")

    new_stamp.should be_a String
    new_stamp.should contain "1:20:"
    new_stamp.should contain ":myemail@email.com::"

    # using all of the args - different combinations
    custom_stamp = Hashcash.generate("hello@email.com", bits: 16)
    custom_stamp.should be_a String
    custom_stamp.should contain "1:16:"
    custom_stamp.should contain ":hello@email.com::"

    custom_stamp2 = Hashcash.generate("hello@email.com", version: "2", bits: 12, date: Time.utc(2016, 2, 15, 10, 20, 30), ext: "bye")
    custom_stamp2.should be_a String
    custom_stamp2.should contain "2:12:160215102030:hello@email.com:bye:"

    custom_stamp3 = Hashcash.generate("hello@email.com", date: Time.utc(2016, 2, 15, 10, 20, 30), bits: 12, ext: "bye", version: "2")
    custom_stamp3.should be_a String
    custom_stamp3.should contain "2:12:160215102030:hello@email.com:bye:"
  end

  it ".verify?" do
    string = "1:20:210106063543:hello::/MD1O8MscgavDI6z:MzkyMjM3Ng=="

    Hashcash.verify?(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30)).should be_true
    Hashcash.verify?(string, "hello", Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2019, 12, 7, 23, 22, 33)).should be_false
    Hashcash.verify?(string, "goodbye").should be_false
    Hashcash.verify?(string, "hello", Time.utc(2016, 2, 15, 10, 20, 30)..Time.utc(2017, 2, 15, 10, 20, 30)).should be_false
    Hashcash.verify?(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30), 40).should be_false
  end

  it ".verify!" do
    string = "1:20:210106063543:hello::/MD1O8MscgavDI6z:MzkyMjM3Ng=="

    Hashcash.verify!(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30)).should be_nil

    expect_raises(Expired) { Hashcash.verify!(string, "hello", Time.utc(2018, 2, 15, 10, 20, 30)..Time.utc(2019, 2, 15, 10, 20, 30)) }
    expect_raises(InvalidResource) { Hashcash.verify!(string, "goodbye") }
    expect_raises(InvalidPreimage) { Hashcash.verify!("1:20:210107002222:hello::4eGAF9pYLrO7AuT8:MA==", "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30)) }
  end
end
