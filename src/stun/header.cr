require "./exceptions"

# raw = uninitialized UInt8[2] # NOTE -- this is cool for something maybe..
module Stun
    
  struct StunHeader
    property msg_type       : UInt16
    property length         : UInt16
    property magic_cookie   : UInt32
    property transaction_id : Bytes
    
    BINDING_REQ_VALUE = 0x0001_u16
    MAGIC_COOKIE      = 0x2112a442_u32
    
    def initialize
      @msg_type       = BINDING_REQ_VALUE
      @length         = 0x0000_u16
      @magic_cookie   = MAGIC_COOKIE
      @transaction_id = "abcdefghijkl".to_slice # TODO -- need to generate 12 byte thing
    end
    
    def initialize(data : Bytes)
      # header is 20 bytes total
      @msg_type = IO::ByteFormat::NetworkEndian.decode(UInt16, data[0,2]) # 2 bytes
      @length = IO::ByteFormat::NetworkEndian.decode(UInt16, data[2,2]) # 2 bytes
      @magic_cookie = IO::ByteFormat::NetworkEndian.decode(UInt32, data[4,4]) #  4 bytes
      @transaction_id = data[8,12] # 96 bits or 12 bytes
      
      raise InvalidStunMessage.new if @magic_cookie != MAGIC_COOKIE
      raise InvalidStunMessage.new if @msg_type != BINDING_REQ_VALUE
      raise InvalidStunMessage.new if @length != data.size - 20

    end
    
    def binding_request?
      @msg_type == BINDING_REQ_VALUE
    end
    
    def serialize
      io = IO::Memory.new
      io.write_bytes(@msg_type, IO::ByteFormat::NetworkEndian)
      io.write_bytes(@length, IO::ByteFormat::NetworkEndian)
      io.write_bytes(@magic_cookie, IO::ByteFormat::NetworkEndian)
      io.write(@transaction_id)
      return io
    end
    
  end
end
