require "../../src/controllers/sip_server"

describe Controllers::SIPServer do

  describe ".new" do
    it "should start" do
      sip_server = Controllers::SIPServer.new
      sip_server.listen
    end
  end
  
end
