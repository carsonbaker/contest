require "./conf"
require "./src/controllers/sip_server"
require "./src/controllers/web_socket_server"

puts "** CONTEST running"

# Set up SIP server
ss = Controllers::SIPServer.new
spawn { ss.listen }

# Set up WebRTC WebSocket server
wss = HTTP::Server.new(Conf::SERVER_LISTEN_ADDRESS, Conf::WEB_RTC_PORT, WebSocketServer.handler)
puts "-> WebRTC server listening on #{Conf::SERVER_LISTEN_ADDRESS}:#{Conf::WEB_RTC_PORT}"
spawn { wss.listen }

# A little delay to let the servers start before we push a newline
sleep 0.2
puts ""

sleep
