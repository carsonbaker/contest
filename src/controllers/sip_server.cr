require "socket"
require "../sip/session"

# sip call with music
# sip:music@iptel.org

module Controllers
  class SIPServer

    def listen
      # just a single thread right now
      interface_addr = Socket::IPAddress.new(Conf::SERVER_LISTEN_ADDRESS,  Conf::DEFAULT_SIP_PORT)
      
      # THREAD_COUNT.times do...
      session = SIP::Session.new(interface_addr)
      spawn do
        session.run
      end
    end
  end
  
end
