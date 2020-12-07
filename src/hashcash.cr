# TODO: Write documentation for `Hashcash`

require "base64"
require "digest/sha1"

module Hashcash
  VERSION       = "0.1.0"
  STAMP_VERSION = 1

  # Hashcash.generate("resource")
  # => 1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==
  # OR can customise hashcash defaults
  # Hashcash.generate("hello", version: 1, bits: 16, date: Time.utc, ext: "goodbyye")
  # => 1:16:201206222403:hello:goodbyye:kfwaGRadlD3ddc9G:MTMxMzY5NQ==
  def self.generate(
    resource : String, *,
    version = 1,
    bits = 20,
    date = Time.utc,
    ext = ""
  )
    Hashcash::Stamp.new(resource, version, bits, date, ext).generate
  end

  # Hashcash.verify("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==")
  # => true
  # Hashcash.verify("invalid_string")
  # => false
  def self.verify(hashcash_stamp : String, resource : String) : Bool
    # make resource arg optional

    # verifies the string return boolean
    Hashcash::Stamp.new(resource).verify_stamp(hashcash_stamp, resource)
  end

  class Stamp
    getter version, bits, date, resource, ext, stamp_string

    def initialize(
      @resource : String,
      @version = STAMP_VERSION,
      @bits = 20,
      @date = Time.utc,
      @ext = "",
      @stamp_string = ""
    )
    end

    def generate : String
      random_string = Random::Secure.base64(12)

      first_part = "#{@version}:#{@bits}:#{@date.to_s("%y%m%d%H%M%S")}:#{@resource}:#{@ext}:#{random_string}:"

      counter = 0
      stamp_string = ""
      while stamp_string == ""
        test_stamp = first_part + Base64.encode(counter.to_s)

        # check that the first @bits bits are 0s
        digest = Digest::SHA1.digest test_stamp
        stamp_string = test_stamp if check digest

        counter += 1
      end

      @stamp_string = stamp_string
    end

    def self.parse(stamp : String)
      parts = stamp.split(":")
      version, bits, date, resource, ext = parts
      Hashcash::Stamp.new(
        resource,
        version.to_i,
        bits.to_i,
        Time.parse_utc(date, "%y%m%d%H%M%S"),
        ext,
        stamp
      )
    end

    def verify_stamp(
      stamp : String, 
      resource = @resource, 
      expiry = 2.days, 
      bits = 20
    )
      hashcash = Hashcash::Stamp.parse(stamp)

      # check the stamp is correct format?

      # check for correct resource
      # raise "Stamp is not valid for the given resource(s)." unless stamp.includes? resource
      return false unless hashcash.resource == resource

      # # check date is within expiry
      # raise "Stamp is expired/not yet valid" if (Time.utc - date) > expiry
      return false if (Time.utc - hashcash.date) > expiry

      # # check 0 bits in stamp
      digest = Digest::SHA1.digest stamp
      # raise "Invalid stamp, not enough 0 bits" unless check digest
      return false unless check digest

      true
    end

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
