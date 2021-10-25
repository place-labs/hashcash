require "base64"
require "digest/sha1"

require "./hashcash/stamp"
require "./hashcash/error"

module Hashcash
  # ```
  # Hashcash.generate("resource")
  # # => "1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA=="
  #
  # # or, can customise hashcash defaults
  # Hashcash.generate("hello", version: 1, bits: 16, date: Time.utc, ext: "goodbyye")
  # # => "1:16:201206222403:hello:goodbyye:kfwaGRadlD3ddc9G:MTMxMzY5NQ=="
  # ```
  def self.generate(
    resource : String,
    version = "1",
    bits = Stamp::DEFAULT_BITS,
    date = Time.utc,
    ext = ""
  ) : String
    hc = Hashcash::Stamp.new(resource, version, bits, date, ext)
    hc.update_counter
    hc.to_s
  end

  # ```
  # Hashcash.valid?("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource")
  # # => true
  # Hashcash.valid?("invalid_string", "resource")
  # # => false
  # ```
  def self.valid?(
    stamp_string : String,
    resource : String,
    time_window = Stamp::DEFAULT_TIME_WINDOW,
    bits = Stamp::DEFAULT_BITS
  ) : Bool
    valid!(stamp_string, resource, time_window, bits)
    true
  rescue Hashcash::Error
    false
  end

  # ```
  # Hashcash.valid!("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource")
  # # => "1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA=="
  # Hashcash.valid?("invalid_string", "resource")
  # # raises Hashcash::Error
  # ```
  def self.valid!(
    stamp_string : String,
    resource : String,
    time_window = Stamp::DEFAULT_TIME_WINDOW,
    bits = Stamp::DEFAULT_BITS
  ) : String
    stamp = Hashcash::Stamp.parse(stamp_string)

    raise Error.new("Hashcash stamp is invalid for #{resource}") unless stamp.is_for?(resource)
    raise Error.new("Hashcash stamp is expired") unless stamp.valid?(time_window)
    raise Error.new("#{bits} bits required") unless stamp.correct_bits?(bits)

    stamp_string
  end
end
