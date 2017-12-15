require "dotenv"

require "./src/controllers/sip_server"
require "./src/controllers/web_socket_server"

# Load from .env
Dotenv.load!

puts "** CONTEST running"

# Set up SIP server
ss = Controllers::SIPServer.new
spawn { ss.listen }

# Set up WebRTC WebSocket server
wss = HTTP::Server.new(ENV["SERVER_LISTEN_ADDRESS"], ENV["WEB_RTC_PORT"], WebSocketServer.handler)
puts "-> WebRTC server listening on #{ENV["SERVER_LISTEN_ADDRESS"]}:#{ENV["WEB_RTC_PORT"]}"
spawn { wss.listen }

# A little delay to let the servers start before we push a newline
sleep 0.2
puts ""

sleep
