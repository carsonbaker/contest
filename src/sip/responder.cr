require "../sdp/ok_body"
require "../graph/call"
require "./logger"

module SIP
  
  enum ResponseCmd
    TRYING
    RINGING
    OK_SDP_WITH_ICE
    OK_SDP
    OK
    BYE
  end

  class Responder

    def initialize(@call_id : String, @from : String, @to : String, @c_seq : String, @vias : Array(String), @call : Graph::Call)

    end
    
    def reset_c_seq(str : String)
      @c_seq = str
    end

    def generate(cmd : ResponseCmd)
      String.build do |str|
        case cmd
          
        when ResponseCmd::TRYING
          str << "SIP/2.0 100 Trying" << "\r\n"
          str << header(cmd, 0)
          
        when ResponseCmd::RINGING
          str << "SIP/2.0 180 Ringing" << "\r\n"
          str << header(cmd, 0)
          
        when ResponseCmd::OK
          str << "SIP/2.0 200 OK" << "\r\n"
          str << header(cmd, 0)
          
        when ResponseCmd::OK_SDP_WITH_ICE
          str << "SIP/2.0 200 OK" << "\r\n"
          body_str = SDP::OkBody.new(true, @call).body
          str << header(cmd, body_str.size)
          str << "\r\n"
          str << body_str
          
        when ResponseCmd::OK_SDP
          str << "SIP/2.0 200 OK" << "\r\n"
          body_str = SDP::OkBody.new(false, @call).body
          str << header(cmd, body_str.size)
          str << "\r\n"
          str << body_str
          
        end
        str << "\r\n"
      end
    end
    
    private def header(cmd : ResponseCmd, body_size : Int)
      headers = {} of String => String
      headers["Call-ID"]        = @call_id
      headers["From"]           = @from
      headers["To"]             = @to
      headers["CSeq"]           = @c_seq
      headers["Server"]         = "CBSipStack 0.0.1"
      headers["Content-Length"] = body_size.to_s
      
      # headers["Identity"]       = "CyI4+nAkHrH3ntmaxgr01TMxTmtjP7MASwliNRdupRI1vpkXRvZXx1ja9k3W+v1PDsy32MaqZi0M5WfEkXxbgTnPYW0jIoK8HMyY1VT7egt0kk4XrKFCHYWGCl0nB2sNsM9CG4hq+YJZTMaSROoMUBhikVIjnQ8ykeD6UXNOyfI="
      # headers["Identity-Info"]  = "http://localhost:3000/cert"

      if [ResponseCmd::OK_SDP, ResponseCmd::OK_SDP_WITH_ICE, ResponseCmd::RINGING].includes? cmd
        headers["Allow"] = "INVITE,ACK,CANCEL,OPTIONS,BYE"
        headers["Contact"] = "<sip:#{Conf::SERVER_IP_ADDRESS}:#{Conf::DEFAULT_SIP_PORT}>"
      end

      if [ResponseCmd::OK_SDP, ResponseCmd::OK_SDP_WITH_ICE].includes? cmd
        headers["Content-Type"] = "application/sdp"
      end

      String.build do |str|
        @vias.each do |v|
          str << "Via: " << v << "\r\n"
        end

        headers.each do |k, v|
          str << k << ": " << v << "\r\n"
        end
      end
    end
    
    
  end
  
end
