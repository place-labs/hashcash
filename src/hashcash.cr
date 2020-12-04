# TODO: Write documentation for `Hashcash`

require "base64"
require "digest/sha1"

module Hashcash
  VERSION = "0.1.0"

  class Stamp
    getter resource
    getter bits
    getter date
    getter version : Int32
    getter stamp_string : String

    STAMP_VERSION = 1 # move??

    def initialize(
      @resource : String,
      @version = STAMP_VERSION,
      @bits = 20,
      @date = Time.utc,
      @ext = ""
    )
      @stamp_string = generate(@resource)
    end

    def generate(
      @resource : String,
      @version = STAMP_VERSION,
      @bits = 20,
      @date = Time.utc,
      @ext = ""
    ) : String
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
      # version =
      # bits =
      # resource =

      # parse date
      # (@version, @bits, @date, @resource, ext, rand, counter) = stamp_string.split(':')
      # puts @version
      # puts rand
      # puts counter
    end

    def verify_stamp(stamp : String, expiry = Time::Span.new(days: 2), bits = 20)
      split_stamp = stamp.split(":")
      date = Time.parse_utc(split_stamp[2], "%y%m%d%H%M%S")

      resource = split_stamp[3]

      # check for correct resource
      raise "Stamp is not valid for the given resource(s)." unless stamp.includes? resource

      # check date is within expiry
      raise "Stamp is expired/not yet valid" if (Time.utc - date) > expiry

      # check 0 bits in stamp
      raise "Invalid stamp, not enough 0 bits" unless check(Digest::SHA1.digest stamp)

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
