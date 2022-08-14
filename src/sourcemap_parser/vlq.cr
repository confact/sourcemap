module SourceMap
  module VLQ
    # A single base 64 digit can contain 6 bits of data. For the base 64 variable
    # length quantities we use in the source map spec, the first bit is the sign,
    # the next four bits are the actual value, and the 6th bit is the
    # continuation bit. The continuation bit tells us whether there are more
    # digits in this value following this digit.
    #
    #   Continuation
    #   |    Sign
    #   |    |
    #   V    V
    #   101011

    VLQ_BASE_SHIFT = 5
    # binary: 100000
    VLQ_BASE = 1 << VLQ_BASE_SHIFT
    # binary: 011111
    VLQ_BASE_MASK = VLQ_BASE - 1
    # binary: 100000
    VLQ_CONTINUATION_BIT = VLQ_BASE
    BASE64_DIGITS        = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".split("")
    BASE64_VALUES        = {"A" => 0, "B" => 1, "C" => 2, "D" => 3, "E" => 4, "F" => 5, "G" => 6, "H" => 7, "I" => 8, "J" => 9, "K" => 10, "L" => 11, "M" => 12, "N" => 13, "O" => 14, "P" => 15, "Q" => 16, "R" => 17, "S" => 18, "T" => 19, "U" => 20, "V" => 21, "W" => 22, "X" => 23, "Y" => 24, "Z" => 25, "a" => 26, "b" => 27, "c" => 28, "d" => 29, "e" => 30, "f" => 31, "g" => 32, "h" => 33, "i" => 34, "j" => 35, "k" => 36, "l" => 37, "m" => 38, "n" => 39, "o" => 40, "p" => 41, "q" => 42, "r" => 43, "s" => 44, "t" => 45, "u" => 46, "v" => 47, "w" => 48, "x" => 49, "y" => 50, "z" => 51, "0" => 52, "1" => 53, "2" => 54, "3" => 55, "4" => 56, "5" => 57, "6" => 58, "7" => 59, "8" => 60, "9" => 61, "+" => 62, "/" => 63, nil => 64}

    # Returns the base 64 VLQ encoded value.
    def self.encode(int)
      vlq = to_vlq_signed(int)
      encoded = ""

      while vlq > 0
        begin
          digit = vlq & VLQ_BASE_MASK
          vlq >>= VLQ_BASE_SHIFT
          digit |= VLQ_CONTINUATION_BIT if vlq > 0
          encoded << base64_encode(digit)
        end
      end

      encoded
    end

    # Decodes the next base 64 VLQ value from the given string and returns the
    # value and the rest of the string.
    def self.decode(str : String) : Array(Int32)
      result = [] of Int32
      chars = str.split("")
      while !chars.empty?
        vlq = 0
        shift = 0
        continuation = true
        while continuation
          char = chars.shift
          raise "error" unless char
          digit = base64_decode(char)
          continuation = false if (digit & VLQ_CONTINUATION_BIT) == 0
          digit &= VLQ_BASE_MASK
          vlq += digit << shift
          shift += VLQ_BASE_SHIFT
        end
        result << from_vlq_signed(vlq)
      end
      result
    end

    protected def self.base64_encode(int)
      BASE64_DIGITS[int] || raise Exception.new("#{int} is not a valid base64 digit")
    end

    protected def self.base64_decode(char : String)
      BASE64_VALUES[char] || raise Exception.new("#{char} is not a valid base64 digit")
    end

    # Converts from a two's-complement integer to an integer where the
    # sign bit is placed in the least significant bit. For example, as decimals:
    #  1 becomes 2 (10 binary), -1 becomes 3 (11 binary)
    #  2 becomes 4 (100 binary), -2 becomes 5 (101 binary)
    protected def self.to_vlq_signed(int)
      if int < 0
        ((-int) << 1) + 1
      else
        int << 1
      end
    end

    # Converts to a two's-complement value from a value where the sign bit is
    # placed in the least significant bit. For example, as decimals:
    #
    #  2 (10 binary) becomes 1, 3 (11 binary) becomes -1
    #  4 (100 binary) becomes 2, 5 (101 binary) becomes -2
    protected def self.from_vlq_signed(vlq)
      if vlq & 1 == 1
        -(vlq >> 1)
      else
        vlq >> 1
      end
    end
  end
end
