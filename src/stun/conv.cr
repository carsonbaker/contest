require "digest"
require "crc32"
require "openssl/hmac"

require "../graph/collection"

require "./header"
require "./exceptions"

# TODO - this doesn't work with ipv6 yet..

module Stun
  class Conv

    struct StunAttributes
    
      enum AttrType : UInt16
        XorMappedAddress        = 0x0020
        Username                = 0x0006
        NetworkCostExperimental = 0xc057
        IceControlling          = 0x802a
        UseCandidate            = 0x0025
        Priority                = 0x0024
        MessageIntegrity        = 0x0008
        Fingerprint             = 0x8028
        Software                = 0x8022
      end
      
      getter attributes
    
      def initialize(@data : Bytes)
        
        @attributes = {} of AttrType => Bytes
        
        byte_step = 0

        while(byte_step < @data.size)
          
          # read the 4 bytes of the attribute length and type
          attr_type = IO::ByteFormat::NetworkEndian.decode(UInt16, @data[byte_step,2])
          attr_len = IO::ByteFormat::NetworkEndian.decode(UInt16, @data[byte_step+2,2])

          byte_step += 4
    
          # and now read the attribute
          @attributes[AttrType.new(attr_type)] = @data[byte_step, attr_len]

          # skip the padding and take us to the next attribute
          # http://stackoverflow.com/questions/11642210/computing-padding-required-for-n-byte-alignment
          # I have no clue why this works! Thank you Stack Overflow...
          byte_step += attr_len + 3 & ~3

        end
        
      end
    end
    
    getter stun_header : StunHeader
    property password : String | Nil
    
    STUN_HEADER_LENGTH = 20
    
    @software_name : String
    
    def initialize(@data : Bytes, @from_address : Socket::IPAddress)
      @password = nil
      @software_name = "Whatever"
      @stun_header = StunHeader.new(@data)
    end
    
    def initialize(@data : Bytes, @from_address : Socket::IPAddress, @password : String)
      @software_name = "Whatever"
      @stun_header = StunHeader.new(@data)
    end
    
    def reply
      
      reply_header = @stun_header.dup
      reply_header.msg_type = 0x0101_u16 # binding request success
      reply_header.length = 12_u16 # 12 bytes of xor mapped address attribute
      data_io = reply_header.serialize
      
      if @stun_header.length == 0
        # Form the basic reply without all the crazy attributes
        write_xor_mapped_address_attr(data_io)
        set_length(data_io, 12)
      else
        # Form the extended reply
        write_software_attribute(data_io)
        write_xor_mapped_address_attr(data_io)
        set_length(data_io, data_io.size + 4)         
        write_message_integrity(data_io)        
        set_length(data_io, data_io.size - 0x0c) # (12 decimal) 0x0c is ... 
        write_fingerprint(data_io)        
        set_length(data_io, data_io.size - 0x14) # (20 decimal) 0x14 is the length of the header    
      end
      
      return data_io.to_slice
      
    end
    
    def set_software_name(vendor : String)
      @software_name = vendor
    end
    
    private def stun_attributes
      raise NoStunAttributes.new if @stun_header.length == 0
      @stun_attributes ||= StunAttributes.new(@data[STUN_HEADER_LENGTH, @stun_header.length])
    end
    
    private def xor_port
      @xor_port ||= (@from_address.port.to_u16 ^ 0x2112).as(UInt16)
    end
    
    private def xor_ipv4_addr
      addr_bytes = @from_address.to_unsafe
      sa_data = addr_bytes.value.sa_data.to_unsafe + 2 # offset 2 bytes to get to ipv4 addr
      ipv4_addr = sa_data.as(UInt32*).value
      @xor_ipv4_addr ||= (ipv4_addr ^ 0x42a41221).as(UInt32) # this is the magic cookie backwards...
    end
    
    private def set_length(io : IO::Memory, length)
      fin = io.pos
      io.seek(2)
      io.write_bytes(length.to_u16, IO::ByteFormat::NetworkEndian)
      io.seek(fin)
    end
    
    def username : String | Nil
      stun_attributes.attributes[StunAttributes::AttrType::Username]?.try do |username_bytes|
        String.new(username_bytes.to_slice)
      end
    end

    private def write_xor_mapped_address_attr(io : IO::Memory)
      # Set the attribute type to XOR-MAPPED-ADDRESS
      io.write_bytes(StunAttributes::AttrType::XorMappedAddress.value, IO::ByteFormat::NetworkEndian)
      
      # Set the attribute length to 8 bytes
      io.write_bytes(0x0008_u16, IO::ByteFormat::NetworkEndian)
      
      # Set the protocol family to ipv4
      io.write_bytes(0x0001_u16, IO::ByteFormat::NetworkEndian)

      # What port did we see from sender? XOR that with the first two bytes of the magic cookie.
      io.write_bytes(xor_port, IO::ByteFormat::NetworkEndian)
      
      # What ip address did we see from sender? XOR that with the four bytes of the magic cookie.
      io.write_bytes(xor_ipv4_addr, IO::ByteFormat::LittleEndian)
    end
    
    private def write_software_attribute(io : IO::Memory)
      io.write_bytes(StunAttributes::AttrType::Software.value, IO::ByteFormat::NetworkEndian)
      len = @software_name.size
      pad = (4 - ( 0x3 & len )) & 0x3
      # ugh the test spec used 0x20 for padding rather than 0x00. this hack fixes the test.
      len -= 1 if @software_name == "test vector "
      io.write_bytes(len.to_u16, IO::ByteFormat::NetworkEndian)
      io.write(@software_name.to_slice)
      io.write(Bytes.new(pad))
    end
    
    private def write_message_integrity(io : IO::Memory)
      # Compute MESSAGE INTEGRITY attribute
      # Compute the SHA-1 of the entire reply up to this point.
      @password.try do |password|
        msg_integrity_bytes = OpenSSL::HMAC.digest(:sha1, password, io)
        io.write_bytes(StunAttributes::AttrType::MessageIntegrity.value, IO::ByteFormat::NetworkEndian)
        io.write_bytes(20_u16, IO::ByteFormat::NetworkEndian) # hmac hashes are always 20 bytes long
        io.write(msg_integrity_bytes)
      end
    end
    
    private def write_fingerprint(io : IO::Memory)
      crc32 = CRC32.checksum(io)
      fingerprint_xor_thing = 0x5354554e
      # fingerprint_xor_thing = 0x4e555453
      xor_crc32 = crc32 ^ fingerprint_xor_thing
      
      io.write_bytes(StunAttributes::AttrType::Fingerprint.value, IO::ByteFormat::NetworkEndian)
      io.write_bytes(4_u16, IO::ByteFormat::NetworkEndian) # crc32 has a 4 byte length
      io.write_bytes(xor_crc32, IO::ByteFormat::NetworkEndian)
    end

  end
end
