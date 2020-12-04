require "./spec_helper"

describe Hashcash do
  it "should initialise a new hashcash instance" do
    new_stamp = Hashcash::Stamp.new("gab@place.technology")

    new_stamp.stamp_string.should contain "gab@place.technology"
    new_stamp.resource.should eq "gab@place.technology"
    new_stamp.bits.should eq 20
    new_stamp.date.hour.should eq Time.utc.hour
    new_stamp.version.should eq 1
  end

  # test generate method
  it "should generate a hashcash stamp string" do
    new_stamp = Hashcash::Stamp.new("gab@place.technology")
    new_stamp_string = new_stamp.generate("hello")

    new_stamp_string.should contain "hello"
    new_stamp_string[0].should eq '1'
    new_stamp_string.should contain "1:20:"
    new_stamp.stamp_string.should contain "hello"
  end

  # test verify method
  it "should verify a valid hashcash stamp" do
    new_stamp = Hashcash::Stamp.new("gab@place.technology")
    new_stamp_string = new_stamp.stamp_string
    # puts new_stamp
    # puts new_stamp_string
    new_stamp.verify_stamp(new_stamp_string)
  end

  it "should not verify an invalid hashcash stamp" do
  end
end
