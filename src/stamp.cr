class Hashcash::Stamp
  STAMP_VERSION = "1"
  getter version, bits, date, resource, ext, rand, counter

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

  def update_counter
    until check (Digest::SHA1.digest self.to_s), bits
      @counter += 1
    end
  end

  def to_s(io : IO) : Nil
    io << version
    io << ':'
    io << bits
    io << ':'
    io << date.to_s("%y%m%d%H%M%S")
    io << ':'
    io << resource
    io << ':'
    io << ext
    io << ':'
    io << rand
    io << ':'
    io << Base64.encode(counter.to_s).chomp
  end

  def self.parse(stamp : String)
    raise "Invalid stamp format, should contain 6 colons (:)" unless stamp.count(':') == 6
    parts = stamp.split(":")
    version, bits, date, resource, ext, rand, counter = parts

    raise "Stamp version #{version} not supported" unless version == STAMP_VERSION.to_s

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

  def valid?(window : Range(Time, Time) = 2.days.ago..2.days.from_now) : Bool
    window.includes?(date)
  end

  def correct_bits?(bits = bits) : Bool
    digest = Digest::SHA1.digest self.to_s
    check(digest, bits)
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
