require "base64"
require "digest/sha1"
require "./stamp"
require "./exceptions"

module Hashcash
  # Hashcash.generate("resource")
  # => 1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==
  # OR can customise hashcash defaults
  # Hashcash.generate("hello", version: 1, bits: 16, date: Time.utc, ext: "goodbyye")
  # => 1:16:201206222403:hello:goodbyye:kfwaGRadlD3ddc9G:MTMxMzY5NQ==
  def self.generate(
    resource : String,
    version = 1,
    bits = 20,
    date = Time.utc,
    ext = ""
  ) : String
    hc = Hashcash::Stamp.new(resource, version, bits, date, ext)
    hc.update_counter
    hc.to_s
  end

  # Hashcash.verify?("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource")
  # => true
  # Hashcash.verify?("invalid_string", "resource")
  # => false
  def self.verify?(
    stamp_string : String,
    resource : String,
    time_window = 2.days.ago..2.days.from_now,
    bits = 20
  ) : Bool
    stamp = Hashcash::Stamp.parse(stamp_string)
    stamp.is_for?(resource) && stamp.valid?(time_window) && stamp.correct_bits?(bits)
  end

  # TODO doc for this method
  def self.verify!(
    stamp_string : String,
    resource : String,
    time_window = 2.days.ago..2.days.from_now,
    bits = 20
  ) : Nil
    stamp = Hashcash::Stamp.parse(stamp_string)

    case
    when !stamp.is_for?(resource)
      raise InvalidResource.new("Hashcash stamp is invalid for #{resource}")
    when !stamp.valid?(time_window)
      raise Expired.new("Hashcash stamp is expired")
    when !stamp.correct_bits?(bits)
      raise InvalidPreimage.new("#{bits} bits required")
    else
      nil
    end
  end
end
