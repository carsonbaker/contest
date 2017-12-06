require "spec"
require "../../src/codec/mu_law"

describe Codec::MuLaw do
  
  it "gets the numbers right" do
    
    mle = Codec::MuLaw.new
    mle.encode_sample(Int16.new( -8159)).should eq(0x1f)
    mle.encode_sample(Int16.new(     0)).should eq(0xff)
    mle.encode_sample(Int16.new(   100)).should eq(0xf2)
    mle.encode_sample(Int16.new(-16000)).should eq(0x10)
    mle.encode_sample(Int16.new(     1)).should eq(0xff)
    mle.encode_sample(Int16.new(  9999)).should eq(0x9c)
    mle.encode_sample(Int16.new( -4283)).should eq(0x2e)
    mle.encode_sample(Int16.new( -4250)).should eq(0x2e)

    mle.decode_sample(UInt8.new( 0x2e)).should eq(Int16.new(-4092))
    mle.decode_sample(UInt8.new( 0xff)).should eq(Int16.new(0))

  end

end
