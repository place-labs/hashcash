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
  )
    Hashcash::Stamp.new(resource, version, bits, date, ext).update_counter.to_s
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
end
