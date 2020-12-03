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

    # new_stamp = HashCash::Stamp.new("resource@resource.com")
    # my_stamp_string = new_stamp.stamp_string
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

      first_part = "#{@version}:#{@bits}:#{date_to_str(@date)}:#{@resource}:#{@ext}:#{random_string}:"

      counter = 0
      stamp_string = ""
      while stamp_string == ""
        test_stamp = first_part + Base64.encode(counter.to_s)

        # check that the first @bits bits are 0s
        digest = Digest::SHA1.digest test_stamp
        stamp_string = test_stamp if check digest

        counter += 1
      end

      stamp_string
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
    def self.verify_stamp(resource : String, expiry = Time::Span.new(days: 2), bits = 20)
      # conditions that it would not be valid here
      # => false
      puts resource
      puts expiry
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

# new_stamp = HashCash::Stamp.new("gab@place.technology")
# puts new_stamp
# puts new_stamp.stamp_string
# puts new_stamp.stamp_string
# puts new_stamp
# puts new_stamp.stamp_string

# stamp_string_new = new_stamp.genenerate(hello)
# puts stamp_string_new
# verified_stamp = HashCash::Stamp.verify("hello")
# puts verified_stamp

# HashCash::Stamp.parse("1:20:201203063636:gab@place.technology::0c45PmF/pKa7+FEF:MTUyODI5Ng==")

# my_stamp_string = HashCash::Stamp.new("resource@resource.com")
# puts my_stamp_string.stamp_string

# generate_stamp_string = my_stamp_string.generate("resource2")
# puts generate_stamp_string
# # p! my_stamp_string = new_stamp.stamp_string

# require "hashcash"
# verfied = verify_stamp("1:20:201203234043:resource@resource.com::ncMrEHUJBxZRKwsO:OTM2MDM=")
