# TODO: Write documentation for `Hashcash`

require "base64"
# require "openssl"
require "digest/sha1"

module HashCash
  VERSION = "0.1.0"

  class Stamp
    # put getters here
    getter resource
    getter bits
    getter date
    getter version : Int32
    getter stamp_string : String

    STAMP_VERSION = 1 # move??

    # new_stamp = HashCash::Stamp.new("hello"")
    #
    # This creates a 20 bit hash cash stamp, which can be retrieved using
    # the stamp_string() attribute reader method.
    #
    # Optionally, the parameters bits and date can be passed to the
    # method to change the number of bits the stamp is worth and the issuance
    # date (which is checked on the server for an expiry with a default
    # deviance of 2 days, pass a Time object).

    def initialize(@resource : String, @bits = 20, @date = Time.utc, @version = STAMP_VERSION)
      @stamp_string = "" # generate_stamp_string
    end

    def generate_stamp_string
      random_string = Random::Secure.base64(12)

      first_part = "#{@version}:#{@bits}:#{date_to_str(@date)}:#{@resource}::#{random_string}:"

      counter = 0

      while @stamp_string == ""
        test_stamp = first_part + Base64.encode(counter.to_s)

        # check that the first @bits bits are 0s
        unpack = Digest::SHA1.digest(test_stamp) # change var name

        last_byte = (@bits/8).floor.to_i

        important_bytes = [] of UInt8
        unpack[0..(last_byte - 1)].each do |byte|
          important_bytes << byte
        end
        # puts bits % 8
        important_bytes << unpack[last_byte].bits(0..@bits % 8)

        @stamp_string = test_stamp if important_bytes.uniq == [0]

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
  end
end
