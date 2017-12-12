require "../srtp_decrypt/lib"
require "../brain/handler"
require "../brain/voicemail_handler"
require "../transport/generic"
require "../sip/responder"

module Graph
  class Call
    property! to : String
    property! call_id : String
    property! server_userfrag : String
    property! client_userfrag : String?
    property! server_password : String
    property! client_password : String?

    property! handler : Brain::Handler
    property! responder : SIP::Responder?

    def formed_username
      client_userfrag.try do |cuf|
        server_userfrag + ":" + cuf
      end
    end

    def destroy
      Graph::Collection.remove(self)
      handler.finalize
    end

    def initialize(&block)
      yield(self)
    end
  end
end
