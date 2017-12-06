require "socket"

class StunFixtures
    
  # packets captured via WireShark

  # Session Traversal Utilities for NAT
  #     [Response In: 6904]
  #     Message Type: 0x0001 (Binding Request)
  #     Message Length: 786
  #     Message Cookie: 2112a442
  #     Message Transaction ID: 423646715a30697656306478
    
  def self.stun_pkt_1
    UInt8.slice(
      0x00, 0x01, 0x00, 0x00, 0x21, 0x12, 0xa4, 0x42,
      0x42, 0x36, 0x46, 0x71, 0x5a, 0x30, 0x69, 0x76,
      0x56, 0x30, 0x64, 0x78)
  end

  # Session Traversal Utilities for NAT
  #     [Response In: 6905]
  #     Message Type: 0x0001 (Binding Request)
  #     Message Length: 0
  #     Message Cookie: 2112a442
  #     Message Transaction ID: 486e6e79426858726d6e3359

  def self.stun_pkt_2
    # just demonstrating to myself two ways of doing the same thing
    "000100002112a442486e6e79426858726d6e3359".hexbytes
    # UInt8.slice(
    #   0x00, 0x01, 0x00, 0x00, 0x21, 0x12, 0xa4, 0x42,
    #   0x48, 0x6e, 0x6e, 0x79, 0x42, 0x68, 0x58, 0x72,
    #   0x6d, 0x6e, 0x33, 0x59)
  end

  # Just garbage I made up
  def self.bad_pkt
    UInt8.slice(
      0x0a, 0xa0, 0x10, 0x01, 0x34, 0x69, 0xc5, 0xf2,
      0x14, 0x1e, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
      0x8d, 0xae, 0x13, 0x50)
  end
  
  def self.stun_reply_1
    # another way of getting the Slice[UInt8] or Bytes
    hex2bytes("01 01 00 0c 21 12 a4 42 42 36 46 71 5a 30 69 76
               56 30 64 78 00 20 00 08 00 01 e3 a8 68 e2 a5 53")
  end

  def self.random_ip_addr  
    Socket::IPAddress.new("73.240.1.17", 49850)
  end
  
  def self.hex2bytes(str)
    str.delete(' ').delete("\n").hexbytes
  end

  def self.rfc5769_sample_stun_req
    hex2bytes("00 01 00 58 21 12 a4 42 b7 e7 a7 01 bc 34 d6 86
               fa 87 df ae 80 22 00 10 53 54 55 4e 20 74 65 73
               74 20 63 6c 69 65 6e 74 00 24 00 04 6e 00 01 ff
               80 29 00 08 93 2f f9 b1 51 26 3b 36 00 06 00 09
               65 76 74 6a 3a 68 36 76 59 20 20 20 00 08 00 14
               9a ea a7 0c bf d8 cb 56 78 1e f2 b5 b2 d3 f2 49
               c1 b5 71 a2 80 28 00 04 e5 7a 3b cf")
  end
  
  def self.rfc5769_sample_stun_expected_reply
    hex2bytes("01 01 00 3c 21 12 a4 42 b7 e7 a7 01 bc 34 d6 86
               fa 87 df ae 80 22 00 0b 74 65 73 74 20 76 65 63
               74 6f 72 20 00 20 00 08 00 01 a1 47 e1 12 a6 43
               00 08 00 14 2b 91 f5 99 fd 9e 90 c3 8c 74 89 f9
               2a f9 ba 53 f0 6b e7 d7 80 28 00 04 c0 7d 4c 96")
  end

  def self.wireshark_capture_1_req
    # 199.7.175.74	192.168.1.110	STUN	174	Binding Request user: nLe1:kbWOedbC

    # ACK
    # a=ice-ufrag:nLe1
    # a=ice-pwd:3ZJ0XF04hhN6eOknxvUjAbRe
    
    # OK
    # a=ice-ufrag:kbWOedbC
    # a=ice-pwd:JPIVLxh8sMElF6CSmRZrbOVtZR

    hex2bytes("00 01 00 50 21 12 a4 42 4e 61 47 6a 6d 6b 4e 32
    57 66 59 6d 00 06 00 0d 6b 62 57 4f 65 64 62 43
    3a 6e 4c 65 31 00 00 00 c0 57 00 04 00 01 00 0a
    80 29 00 08 51 01 0a c5 98 f9 bc 7f 00 24 00 04
    6e 7e 1e ff 00 08 00 14 65 1a d0 a4 1c 96 eb 0d
    b2 c1 1e d5 3e c0 2f 64 ad fd 23 d6 80 28 00 04
    79 9c 6b 21")
  end
  
  def self.wireshark_capture_1_reply
    
    # 199.7.175.74	192.168.1.110	STUN	146	Binding Success Response XOR-MAPPED-ADDRESS: 73.157.246.157:55418
    
    hex2bytes("01 01 00 54 21 12 a4 42 4e 61 47 6a 6d 6b 4e 32
               57 66 59 6d 80 22 00 23 72 74 70 65 6e 67 69 6e
               65 2d 35 2e 31 2e 31 2d 33 2e 30 33 63 61 35 32
               34 2e 6a 6e 63 74 6e 2e 65 6c 37 00 00 20 00 08
               00 01 f9 68 68 8f 52 df 00 08 00 14 93 fe 3d 8a
               ae 93 2c 18 be 86 9a 39 65 6a eb 9d 29 79 87 ff
               80 28 00 04 5b ae fa a3")
  end
  
end
