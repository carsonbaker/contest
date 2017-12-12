require "./conf"
require "./src/controllers/sip_server"
require "./src/controllers/web_socket_server"

# Set up SIP server
ss = Controllers::SIPServer.new
spawn { ss.listen }

# Set up WebRTC WebSocket server
wss = HTTP::Server.new(Conf::SERVER_LISTEN_ADDRESS, Conf::WEB_RTC_PORT, WebSocketServer.handler)
spawn { wss.listen }

sleep
