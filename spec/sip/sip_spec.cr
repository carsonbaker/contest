require "spec"
require "../../src/sip/msg"

describe SIP::Msg do

  describe ".new" do
    it "should parse an example SIP message" do
      msg = File.read("spec/sip_test_data/1.txt")
      sip_msg = SIP::Msg.new(msg)
    end
  end
  
end
