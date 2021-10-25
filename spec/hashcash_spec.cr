require "./spec_helper"

describe Hashcash do
  describe ".generate" do
    it "accepts just a resource arg" do
      new_stamp = Hashcash.generate("myemail@email.com")

      new_stamp.should be_a String
      new_stamp.should contain "1:20:"
      new_stamp.should contain ":myemail@email.com::"
    end

    it "accepts a full set of stamp parameters" do
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
  end

  it ".valid?" do
    string = "1:20:210106063543:hello::/MD1O8MscgavDI6z:MzkyMjM3Ng=="

    Hashcash.valid?(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30)).should be_true
    Hashcash.valid?(string, "hello", Time.utc(2019, 12, 7, 23, 22, 33)..Time.utc(2019, 12, 7, 23, 22, 33)).should be_false
    Hashcash.valid?(string, "goodbye").should be_false
    Hashcash.valid?(string, "hello", Time.utc(2016, 2, 15, 10, 20, 30)..Time.utc(2017, 2, 15, 10, 20, 30)).should be_false
    Hashcash.valid?(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30), 40).should be_false
  end

  it ".valid!" do
    string = "1:20:210106063543:hello::/MD1O8MscgavDI6z:MzkyMjM3Ng=="

    Hashcash.valid!(string, "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30)).should eq string

    expect_raises(Hashcash::Error, /stamp is expired/) { Hashcash.valid!(string, "hello", Time.utc(2018, 2, 15, 10, 20, 30)..Time.utc(2019, 2, 15, 10, 20, 30)) }
    expect_raises(Hashcash::Error, /stamp is invalid/) { Hashcash.valid!(string, "goodbye") }
    expect_raises(Hashcash::Error, /20 bits required/) { Hashcash.valid!("1:20:210107002222:hello::4eGAF9pYLrO7AuT8:MA==", "hello", Time.utc(2019, 2, 15, 10, 20, 30)..Time.utc(2050, 2, 15, 10, 20, 30)) }
  end
end
