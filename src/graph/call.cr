require "../srtp_decrypt/lib"
require "../brain/handler"
require "../brain/voicemail_handler"
require "../transport/generic"

module Graph
  
  class Call
    property! to                          : String
    property! call_id                     : String
    property! server_userfrag             : String
    property! client_userfrag             : String?
    property! server_password             : String
    property! client_password             : String?

    property! call_handler                : Brain::Handler
    property! transport                   : Transport::Generic?
    property! responder                   : SIP::Responder?

    def formed_username
      client_userfrag.try do |cuf|
        server_userfrag + ":" + cuf
      end
    end
    
    def destroy
      Graph::Collection.remove(self)
      transport.finalize
    end
    
    def initialize(&block)
      # @transport = Transport::RTP.new
      @call_handler = Brain::VoicemailHandler.new(self)
      
      yield(self)
    end

  end
  
end