require "http/server"
require "http/web_socket"

require "../logger"
require "../transport/srtp"
require "../sip/first_flurry"
require "../sip/session"
require "../sip/msg"

class HTTP::WebSocketHandler
  def call(context)
    context.response.headers["Sec-WebSocket-Protocol"] = "sip"
    previous_def
  end
end

module WebSocketServer
  def self.handle_invite(sip_msg, socket)
    # 1. Just pick the last ICE candidate as the best.. (not the right way to do it...)
    # L.debug "*** ICE Candidates found:"
    # sip_msg.sdp_header.ice_candidates.each do |ice_can|
    #   L.debug ice_can
    # end
    #
    # candidate = sip_msg.sdp_header.ice_candidates.last
    # candidate_addr = Socket::IPAddress.new(candidate[:connection_address], candidate[:port].to_i)

    # 2. Set up transport layer
    opus_port = sip_msg.sdp_header.rtp_map["opus/48000/2"]
    transport = opus_port ? Transport::RTP.new(Codec::Opus.new, opus_port) : Transport::RTP.new(Codec::MuLaw.new, 0)

    # 3. Create a call and add it to our state tracker
    L.info "[Tracking new SIP conversation arriving over WebRTC]"
    call = SIP::Session.start_track_sip_conv(sip_msg, transport)

    # 4. Create a lambda that delivers the SIP response
    send_proc = ->(str : String) do
      response = socket.send(str)
      # TODO - I don't know what I'm doing here...
      Int64.new(0)
    end

    # 5. Respond with our SIP stuff (Trying.. Ringing.. OK..)
    reply = SIP::FirstFlurry.new(sip_msg, true, call) # true value indicates websocket transport
    reply.transmit(send_proc)

    # 6. Transport layer engage!
    spawn { call.handler.listen }

    # The call handler will learn that the call has begun once DTLS has been established
    # notified via the SRTP transport

  end

  def self.handler
    HTTP::WebSocketHandler.new do |socket, context|
      L.debug "Establishing WebSocket #{socket}"

      socket.on_message do |message|
        # 1. Read the SIP invite, arriving over the websocket

        begin
          sip_msg = SIP::Msg.new(message)
        rescue e
          L.error(e.inspect_with_backtrace)
          next
        end

        case sip_msg.sip_header.command
        when "INVITE"
          handle_invite(sip_msg, socket)
        end
      end

      socket.on_close do
        L.debug "Closing WebSocket #{socket}"
      end
    end
  end
end
