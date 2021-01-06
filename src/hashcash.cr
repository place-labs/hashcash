require "base64"
require "digest/sha1"

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
  )
    Hashcash::Stamp.new(resource, version, bits, date, ext).generate
  end

  # Hashcash.verify?("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource")
  # => true
  # Hashcash.verify?("invalid_string", "resource")
  # => false
  def self.verify?(hashcash_stamp : String, resource : String, time_window = 2.days.ago..2.days.from_now, bits = 20) : Bool
    # Hashcash::Stamp.new(resource).valid?(hashcash_stamp, resource, time_window, bits)
    
    # fix
    # parse the stamp
    # verify agains the resource passed in
    stamp = Hashcash::Stamp.parse(hashcash_stamp)
    stamp.valid?(resource, time_window, bits)
  end

  class Stamp
    STAMP_VERSION = 1
    getter version, bits, date, resource, ext, rand
    property counter

    def initialize(
      @resource : String,
      @version = STAMP_VERSION,
      @bits = 20,
      @date = Time.utc,
      @ext = "",
      @rand = Random::Secure.base64(12),
      @counter = 0
    )
    end

    # probably rename # find_valid_counter ? 
    def update_counter
      until check (Digest::SHA1.digest self.to_s)
        @counter += 1
      end
    end

    def to_s(io : IO) : Nil
      "#{@version}:#{@bits}:#{@date.to_s("%y%m%d%H%M%S")}:#{@resource}:#{@ext}:#{@rand}:#{Base64.encode(@counter.to_s)}".chomp
    end



    def self.parse(stamp : String)
      parts = stamp.split(":")
      version, bits, date, resource, ext, rand, counter = parts
      Hashcash::Stamp.new(
        resource,
        version.to_i,
        bits.to_i,
        Time.parse_utc(date, "%y%m%d%H%M%S"),
        ext,
        rand,
        Base64.decode_string(counter).to_i
      )
    end

    def is_for?(resource : String) : Bool
      self.resource == resource
    end

    # def self.is_for?(resource : String) : Bool
    #   @resource == resource
    # end

    def expired?(window : Range(Time, Time) = 2.days.ago..2.days.from_now) : Bool
      !window.includes?(@date)
    end

    def correct_bits?(bits = 20) : Bool
      # remove @stamp_string
      # not working as is
      digest = Digest::SHA1.digest self.to_s
      check(digest, bits)
    end

    def valid?(
      # stamp : String,
      resource : String,
      time_window = 2.day.ago..2.days.from_now,
      bits = 20
    ) : Bool
      # parsed_stamp = Hashcash::Stamp.new("hello")
      parsed_stamp = self
      # puts parsed_stamp
      case
      when !(parsed_stamp.is_for?(resource))
        false
      when parsed_stamp.expired?(time_window)
        false
      when !parsed_stamp.correct_bits?(bits)
        false
      else
        true
      end
    end

    def self.verify!(
      # stamp : String,
      resource : String,
      time_window = 2.day.ago..2.days.from_now,
      bits = 20
    ) : Nil
      parsed_stamp = self
      # Hashcash::Stamp.parse(stamp)
      case
      when !parsed_stamp.is_for?(resource)
        raise "Stamp is not valid for the given resource(s)."
      when parsed_stamp.expired?(time_window)
        raise "Stamp is expired/not yet valid"
      when !parsed_stamp.correct_bits?(bits)
        raise "Invalid stamp, not enough 0 bits"
      else
        true
      end
    end

    # TODO update method to count the number of 0s at the start rather than check it matches
    private def check(digest : Bytes, bits = 20) : Bool
      full_bytes = bits // 8
      extra_bits = bits % 8

      full = digest[0...full_bytes]
      partial = digest[full_bytes]

      return false unless full.all? 0
      partial >> (8 - extra_bits) == 0
    end
  end
end
