require "base64"
require "digest/sha1"
require "./stamp"

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

  def self.verify!(
    stamp_string : String,
    resource : String,
    time_window = 2.days.ago..2.days.from_now,
    bits = 20
  ) : Nil
    stamp = Hashcash::Stamp.parse(stamp_string)
    # stamp.is_for?(resource) && stamp.valid?(time_window) && stamp.correct_bits?(bits)
    # TODO raise errors for each thing
    #     case
    #     when !self.is_for?(resource)
    #       raise "Stamp is not valid for the given resource(s)."
    #     when !self.valid?(time_window)
    #       raise "Stamp is expired/not yet valid"
    #     when !self.correct_bits?(bits)
    #       raise "Invalid stamp, not enough 0 bits"
    #     else
    #       true
    #     end

    # otherwise

    nil
  end
end
