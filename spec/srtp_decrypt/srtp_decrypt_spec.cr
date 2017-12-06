require "spec"
require "../../src/srtp_decrypt/lib"

def srtp_create
  taglen = 10
  # SRTP_AES128_CM_SHA1_80
  return LibSRTPDecrypt.srtp_create(
    LibSRTPDecrypt::SRTP_ENCR_AES_CM,
    LibSRTPDecrypt::SRTP_AUTH_HMAC_SHA1,
    taglen, LibSRTPDecrypt::SRTP_PRF_AES_CM,
    0)
end

describe "whatever" do

  it "should init" do
    
    s = srtp_create
    s.should_not be_nil
    
    key = "abcdefghijklmnop" # must be 16 bytes long
    salt = "abcdefghijklmn" # must be 14 bytes long
    ret = LibSRTPDecrypt.srtp_setkey(s, key, key.size, salt, salt.size)

    ret.should_not eq(Errno::EINVAL) 
    ret.should eq(0) # success
    
  end
  
  it "should decrypt a real payload" do
    
    str = "80 80 63 68 b9 31 ed f7 48 d7 3d a1 c3 eb 6d c5
    56 42 63 32 cd e7 45 d0 a4 00 57 9a ea 15 ac 05
    ea 13 65 77 f4 a2 b2 a0 60 36 7d a8 ec e9 a4 a0
    04 4d 58 93 a5 f5 4a 3a bc 5c e4 4f d1 1a 41 3a
    d8 e5 5a 40 0a 09 29 f5 00 42 cd c2 ab 17 bd 19
    41 07 78 b4 74 12 38 52 07 a4 31 6f c1 92 83 44
    8a 20 64 de b8 4c 84 21 5d 70 b0 da fa 72 25 ea
    9c a3 e7 46 1e 7e 13 3c f2 d8 db b6 26 af 29 c8
    39 8e d0 b8 ee b1 a9 49 53 61 6b 16 85 68 8d aa
    d4 52 11 1a 0a 86 5e 35 3b 60 f3 a8 fe e3 df 1e
    5d 71 fe 50 62 d1 45 dc 08 c3 2d 1f bf bb 37 27
    38 0e cf 3d 12 1b"                            
  
    bytes = str.delete(' ').delete("\n").hexbytes
    
    big_bytes = Bytes.new(bytes.size + 256)
    big_bytes.copy_from(bytes)
    
    material = UInt8.slice(
      247, 214, 66, 54, 179, 85, 66, 171, 31, 57, 203, 55, 140, 86,
      16, 243, 12, 13, 213, 223, 3, 51, 70, 213, 227, 144, 201, 132,
      57, 253, 246, 1, 26, 60, 70, 63, 70, 26, 172, 159, 246, 70,
      82, 197, 120, 218, 22, 5, 96, 107, 141, 142, 41, 89, 2, 4, 101, 37, 181, 252)
  
    s = srtp_create
    s.should_not eq(0)
    
    key = material[0, 16] # must be 16 bytes long
    salt = material[32, 14] # must be 14 bytes long
    
    ret = LibSRTPDecrypt.srtp_setkey(s, key, key.size, salt, salt.size)
    
    ret.should eq(0)

    len = bytes.size.to_u64
    ret = LibSRTPDecrypt.srtp_recv(s, bytes, pointerof(len))
    
    ret.should eq(0)

  end

end
