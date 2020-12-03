# TODO: Write documentation for `Hashcash`

require "base64"
# require "openssl"
require "digest/sha1"

module HashCash
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
      @stamp_string = ""
    end

    # new_string_stamp = HashCash::Stamp.generate("resource@resource.com")
    def generate
      random_string = Random::Secure.base64(12)

      first_part = "#{@version}:#{@bits}:#{date_to_str(@date)}:#{@resource}:#{@ext}:#{random_string}:"

      counter = 0

      while @stamp_string == ""
        test_stamp = first_part + Base64.encode(counter.to_s)

        # check that the first @bits bits are 0s
        digest = Digest::SHA1.digest test_stamp
        @stamp_string = test_stamp if check digest

        counter += 1
      end

      @stamp_string
    end

    # pass_stamp = HashCash::Stamp.parse("1:20:060408:gab@place.technology::1QTjaYd7niiQA/sc:ePa")
    def self.parse(stamp_string : String)
      # version =
      # bits =
      # resource =

      # parse date
      # (@version, @bits, @date, @resource, ext, rand, counter) = stamp_string.split(':')
      # puts @version
      # puts rand
      # puts counter

    end

    # verify the stamp
    def self.verify(resources : String, bits = 20)
      # conditions that it would not be valid here
      # => false

      # otherwise
      true
    end

    private def date_to_str(date : Time) : String
      if (date.second == 0) && (date.hour == 0) && (date.minute == 0)
        date.to_s("%y%m%d")
      elsif (date.second == 0)
        date.to_s("%y%m%d%H%M")
      else
        date.to_s("%y%m%d%H%M%S")
      end
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
