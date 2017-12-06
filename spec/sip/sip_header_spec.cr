require "spec"
require "string_scanner"

require "../../src/sip/header"

describe SIP::Header do

  describe ".parse_contact_header" do
    it "should parse a simple Contact header" do
      light_contact_header = %(<sip:192.168.33.44:5060>)
      parsing = SIP::Header.parse_contact_header(light_contact_header)
      parsing[:host].should eq("192.168.33.44")
      parsing[:port].should eq(5060)
    end

    it "should parse a semi-complicated Contact header" do
      medium_contact_header = %(<sip:johndoe@188.165.231.34:14063;ws-src-ip=73.157.246.157;>")
      parsing = SIP::Header.parse_contact_header(medium_contact_header)
      parsing[:host].should eq("188.165.231.34")
      parsing[:port].should eq(14063)
    end

    it "should parse a Contact header as used by app.onsip.com" do
      onsip_contact_header = %(<sip:0332p2fs*bcf026qd268b.invalid_ovob8aa9090ff0_ovid36797b86@199.7.175.102;transport=ws;ob;gr>)
      parsing = SIP::Header.parse_contact_header(onsip_contact_header)
      parsing[:host].should eq("199.7.175.102")
      parsing[:port].should eq(nil)
    end

    it "should parse a complicated Contact header" do
      heavy_contact_header = %("johnathan doe"<sip:johnnydoedoeadeerafemaledeer@188.165.231.30:14060;rtcweb-breaker=no;click2call=no;transport=udp;ws-src-ip=73.157.246.157;ws-src-port=53027;ws-src-proto=wss>;+g.oma.sip-im;language="en,fr")
      parsing = SIP::Header.parse_contact_header(heavy_contact_header)
      parsing[:host].should eq("188.165.231.30")
      parsing[:port].should eq(14060)
    end
  end
end
