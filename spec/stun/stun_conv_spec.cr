require "spec"
require "socket"

require "./stun_fixtures"
require "../../src/stun/conv"

def stun_conv_from_rfc5769_sample
  example_password = "VOkJxbRl1RmTxUk/WvJxBt"
  example_mapped_addr = Socket::IPAddress.new("192.0.2.1", 32853)
  c = Stun::Conv.new(StunFixtures.rfc5769_sample_stun_req, example_mapped_addr, example_password)
  c.set_software_name("test vector ") # space is significant here
  return c
end

def stun_conv_from_other_vendor
  example_password = "JPIVLxh8sMElF6CSmRZrbOVtZR"
  example_mapped_addr = Socket::IPAddress.new("73.157.246.157", 55418)
  c = Stun::Conv.new(StunFixtures.wireshark_capture_1_req, example_mapped_addr, example_password)
  c.set_software_name("rtpengine-5.1.1-3.03ca524.jnctn.el7")
  return c
end

describe Stun::Conv do
  
  it "checks the magic cookie to identify STUN packets" do

    ip_addr = StunFixtures.random_ip_addr
    
    # Shouldn't raise an exception..
    sr1 = Stun::Conv.new(StunFixtures.stun_pkt_1, ip_addr)
    sr2 = Stun::Conv.new(StunFixtures.stun_pkt_2, ip_addr)

    expect_raises(Stun::InvalidStunMessage) do
      sr3 = Stun::Conv.new(StunFixtures.bad_pkt, ip_addr)
    end

  end
  
  it "can correctly unpack the length" do
    
    ip_addr = StunFixtures.random_ip_addr

    sr1 = Stun::Conv.new(StunFixtures.stun_pkt_1, ip_addr)
    sr2 = Stun::Conv.new(StunFixtures.stun_pkt_2, ip_addr)
    sr3 = Stun::Conv.new(StunFixtures.rfc5769_sample_stun_req, ip_addr)
        
    sr1.stun_header.length.should eq(0)
    sr2.stun_header.length.should eq(0)
    sr3.stun_header.length.should eq(88)
  end
  
  it "can correctly unpack the transaction id" do
    
    ip_addr = StunFixtures.random_ip_addr
    sr1 = Stun::Conv.new(StunFixtures.stun_pkt_1, ip_addr)

    byte_slice = "423646715a30697656306478".hexbytes
    
    # hexstring = "42 36 46 71 5a 30 69 76 56 30 64 78".hexstring
    # bytes_array = hexstring.split.map(&.to_u8(16))
    
    sr1.stun_header.transaction_id.should eq(byte_slice)

  end
  
  it "can generate a reply" do
    ip_addr = StunFixtures.random_ip_addr
    sr1 = Stun::Conv.new(StunFixtures.stun_pkt_1, ip_addr)
    sr1.reply.should eq(StunFixtures.stun_reply_1)
  end
  
  it "should give the expected reply to the rfc5769 sample conversation" do
    stun_conv_from_rfc5769_sample.reply.should eq(StunFixtures.rfc5769_sample_stun_expected_reply)
  end
  
  it "should be able to parse the username if given" do
    sc = stun_conv_from_rfc5769_sample
    sc.username.should eq "evtj:h6vY"
  end
  
  it "should give the expected reply to a captured conversation from some other vendor" do
    stun_conv_from_other_vendor.reply.should eq(StunFixtures.wireshark_capture_1_reply)
  end
  
end


