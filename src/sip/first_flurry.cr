require "../sdp/ok_body"
require "../graph/collection"
require "./responder"

module SIP

  class FirstFlurry
    
    def initialize(@sip_msg : Msg, @for_websocket : Bool, @call : Graph::Call)
      
      # Modify the To header to add a tag, if necessary
      # TODO - I think this should get moved to the Call class
      tag_sep = ";tag="
      basis = @sip_msg.sip_header.to.split(tag_sep)
      if basis.size == 1 # No tag present, so we have to add our own
        random_str = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
        basis.push random_str
      end
      to_header = basis.join(tag_sep)
      
      @call.responder = Responder.new(
        @sip_msg.sip_header.call_id,
        @sip_msg.sip_header.from,
        to_header,
        @sip_msg.sip_header.cseq,
        @sip_msg.sip_header.vias,
        @call)
      
    end
  
    def transmit(send_proc : Proc)

      begin
        L.info " --> Sending SIP 100 Trying"
        trying_response = @call.responder.generate(ResponseCmd::TRYING)
        send_proc.call(trying_response)

        L.info " --> Sending SIP 180 Ringing"
        ringing_response = @call.responder.generate(ResponseCmd::RINGING)
        send_proc.call(ringing_response)
        
        L.info " --> Sending SIP 200 OK"
        ok_response = @call.responder.generate(@for_websocket ? ResponseCmd::OK_SDP_WITH_ICE : ResponseCmd::OK_SDP)
        send_proc.call(ok_response)
        
      rescue ex : Errno
        if ex.errno == Errno::ECONNREFUSED
          p ex.inspect
        end
      end
    end
  end
  
end
