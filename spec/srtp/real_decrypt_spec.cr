# require "spec"
# require "../../src/srtp/lib"
# 
# describe "cisco srtp" do
#   
#   it "should decrypt some a real packet" do
#   
#     LibSRTP.srtp_init
#     policy = LibSRTP::Srtp_policy_t.new
#      
#     material = UInt8.slice(
#        247, 214, 66, 54, 179, 85, 66, 171, 31, 57, 203, 55, 140, 86,
#        16, 243, 12, 13, 213, 223, 3, 51, 70, 213, 227, 144, 201, 132,
#        57, 253, 246, 1, 26, 60, 70, 63, 70, 26, 172, 159, 246, 70,
#        82, 197, 120, 218, 22, 5, 96, 107, 141, 142, 41, 89, 2, 4, 101, 37, 181, 252)
#     
#     # set policy to describe a policy for an SRTP stream
#     rtp_ptr = pointerof(policy.@rtp) # .@ syntax is unofficial supposedly
#     rtcp_ptr = pointerof(policy.@rtcp)
#     
#     LibSRTP.srtp_crypto_policy_set_rtp_default(rtp_ptr)
#     LibSRTP.srtp_crypto_policy_set_rtcp_default(rtcp_ptr)
#     
#     ssrc = LibSRTP::Srtp_ssrc_t.new
#     ssrc.type = LibSRTP::Srtp_ssrc_type_t::SSRC_ANY_INBOUND # TODO - just picked something at random
#     ssrc.value = 0
#     
#     policy.ssrc = ssrc
#     policy.key  = material
#     policy.nxt = nil
#     
#     LibSRTP.srtp_create(out session, pointerof(policy))
#     
#     str = "80 80 63 68 b9 31 ed f7 48 d7 3d a1 c3 eb 6d c5
#       56 42 63 32 cd e7 45 d0 a4 00 57 9a ea 15 ac 05
#       ea 13 65 77 f4 a2 b2 a0 60 36 7d a8 ec e9 a4 a0
#       04 4d 58 93 a5 f5 4a 3a bc 5c e4 4f d1 1a 41 3a
#       d8 e5 5a 40 0a 09 29 f5 00 42 cd c2 ab 17 bd 19
#       41 07 78 b4 74 12 38 52 07 a4 31 6f c1 92 83 44
#       8a 20 64 de b8 4c 84 21 5d 70 b0 da fa 72 25 ea
#       9c a3 e7 46 1e 7e 13 3c f2 d8 db b6 26 af 29 c8
#       39 8e d0 b8 ee b1 a9 49 53 61 6b 16 85 68 8d aa
#       d4 52 11 1a 0a 86 5e 35 3b 60 f3 a8 fe e3 df 1e
#       5d 71 fe 50 62 d1 45 dc 08 c3 2d 1f bf bb 37 27
#       38 0e cf 3d 12 1b"                            
#   
#     bytes = str.delete(' ').delete("\n").hexbytes
#     
#     len = bytes.size
#         
#     err = LibSRTP.srtp_unprotect(session, bytes, pointerof(len))
#     puts "Len is #{len}"
#     puts "err is #{err}"
#     
#   end
# 
# end


# require "spec"
# require "../../src/srtp/lib"
# 
# describe "whatever" do
# 
#   it "should init" do
#     
#     LibSRTP.srtp_init
#     
#     # session : LibSRTP::Srtp_t
#     policy = LibSRTP::Srtp_policy_t.new
#     
#     key = UInt8.slice(0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
#                      0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
#                      0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
#                      0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D)
#                      
#                      
#     # set policy to describe a policy for an SRTP stream
#     rtp_ptr = pointerof(policy.@rtp) # .@ syntax is unofficial supposedly
#     rtcp_ptr = pointerof(policy.@rtcp)
#     
#     LibSRTP.srtp_crypto_policy_set_rtp_default(rtp_ptr)
#     LibSRTP.srtp_crypto_policy_set_rtcp_default(rtcp_ptr)
#     
#     ssrc = LibSRTP::Srtp_ssrc_t.new
#     ssrc.type = LibSRTP::Srtp_ssrc_type_t::SSRC_ANY_INBOUND # TODO - just picked something at random
#     ssrc.value = "2078917053"
#     
#     policy.ssrc = ssrc
#     policy.key  = key
#     policy.nxt = nil
#     
#     LibSRTP.srtp_create(out session, pointerof(policy))
#     
#     puts session
#     
#     rtp_buffer = Bytes.new(2048)
#     len = 512
#     # len = LibSRTP.get_rtp_packet(rtp_buffer)
#     LibSRTP.srtp_protect(session, rtp_buffer, pointerof(len))
#     puts "Len is #{len}"
#     puts rtp_buffer.hexdump
#     
#   end
# 
# end
