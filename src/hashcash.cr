# TODO: Write documentation for `Hashcash`

require "base64"

module HashCash
  VERSION = "0.1.0"

  class Stamp
    # put getters here
    getter resource : String
    getter bits : Int32
    getter date : Time
    # getter version : Int32
    # getter stamp_string : String

    STAMP_VERSION = 1 # needed???

    # To construct a new HashCash::Stamp object, pass the :resource parameter
    # to it, e.g.
    #
    # new_stamp = HashCash::Stamp.new(:resource => "hashcash@alech.de")
    #
    # This creates a 20 bit hash cash stamp, which can be retrieved using
    # the stamp_string() attribute reader method.
    #
    # Optionally, the parameters :bits and :date can be passed to the
    # method to change the number of bits the stamp is worth and the issuance
    # date (which is checked on the server for an expiry with a default
    # deviance of 2 days, pass a Time object).

    def initialize(resource, bits = 20, date = Time.utc)
      # first validate correct args
      @resource = resource
      @bits = bits.to_i

      raise "date must be a Time object" unless date.class == Time
      @date = date # validate that this is a Time object

      #initialised @stamp_string and @version

      # random_string = Base64.endcode(OpenSSL::Random.random_bytes(12))
      # puts random_string

    end

    # Alternatively, a stamp can be passed to the constructor by passing
    # it as a string to the :stamp parameter, e.g.
    #
    # pass_stamp = HashCash::Stamp.parse("1:20:060408:adam@cypherspace.org::1QTjaYd7niiQA/sc:ePa")


    # verify the stamp
    def self.verify(resources : String, bits = 20)
      # conditions that it would not be valid here 
      # => false

      # otherwise
      true
    end
  end
end

new_stamp = HashCash::Stamp.new("hashcash@alech.de")
puts new_stamp

verified_stamp = HashCash::Stamp.verify("hello")
puts verified_stamp