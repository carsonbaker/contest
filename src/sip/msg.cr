require "./header"
require "../sdp/header"

module SIP

  class Msg
    
    getter sip_header : SIP::Header
    getter sdp_header : SDP::Header
    
    SIP_SEC_DELIMITER = /(\r\n\r\n|\r\r|\n\n)/

    def initialize(str : String)

      splits = str.split(SIP_SEC_DELIMITER)

      if (splits.size != 3)
        raise "Could not separate header and body of SIP message (#{splits.size} splits)"
        return
      end

      header = splits[0]
      body = splits[2]

      @sip_header = SIP::Header.new(header)
      @sdp_header = SDP::Header.new(body)
    end

  end
  
end