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
