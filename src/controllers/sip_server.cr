require "socket"
require "../sip/session"

# sip call with music
# sip:music@iptel.org

module Controllers
  class SIPServer
    def listen
      # just a single thread right now
      interface_addr = Socket::IPAddress.new(ENV["SERVER_LISTEN_ADDRESS"], ENV["DEFAULT_SIP_PORT"])
      puts "-> SIP server listening for UDP packets on #{interface_addr}"
      # THREAD_COUNT.times do...
      session = SIP::Session.new(interface_addr)
      spawn do
        session.run
      end
    end
  end
end
