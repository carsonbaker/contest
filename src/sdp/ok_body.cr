require "../graph/call"
require "../transport/generic"

module SDP
  class OkBody
    SDP_VERSION      = 0
    SDP_SESSION_NAME = "AGoodSessionForMakeGreatGlory"

    def initialize(for_websocket : Bool, call : Graph::Call)
      @session = {} of String => String
      @time = {} of String => String
      @media = [] of String

      rtp_port = call.handler.transport.rtp_port
      rtcp_port = rtp_port + 1

      random_session_id = (0...10).map { rand(9).to_s }.join
      session_version = 1

      srv_ip = ENV["SERVER_IP_ADDRESS"]

      @session["v"] = SDP_VERSION.to_s
      @session["o"] = "- #{random_session_id} #{session_version} IN IP4 #{srv_ip}"
      @session["s"] = SDP_SESSION_NAME
      @session["c"] = "IN IP4 #{srv_ip}"

      @time["t"] = "0 0" # (time the session is active)

      # WebSocket responses are a little different, but I'm not sure if I do TLS and SAVPF...
      # Just copying what other people are doing here.
      if for_websocket
        # @time["m"] = "audio #{chosen_media_port} RTP/AVPF 0" # will only work if --disable-webrtc-encryption is enabled in Chrome canary
        @time["m"] = "audio #{rtp_port} UDP/TLS/RTP/SAVPF 101 0" # the more usual secure version
      else
        @time["m"] = "audio #{rtp_port} RTP/AVP 101 0"
        # @time["m"] = "audio #{rtp_port} RTP/AVP 101"
      end

      @media << "a=rtcp:#{rtcp_port} IN IP4 #{srv_ip}"

      if true # OPUS experiment
        @media << "a=rtpmap:101 opus/48000/2"
      end

      if true # PCMU

        rpawtms = ENV["RTP_PACKET_AUDIO_WALL_TIME_MS"]

        @media << "a=rtpmap:0 PCMU/8000" # (media attribute line)
        # @media << "a=rtpmap:96 telephone-event/8000" # see https://tools.ietf.org/html/rfc4733
        # @media << "a=fmtp:96 0-16"
        #
        # @media << "a=ptime:#{rpawtms}"

      end

      @media << "a=sendrecv"

      # We only do ICE stuff on Websocket connections...
      if for_websocket
        srv_ufrag = call.server_userfrag
        srv_upass = call.server_password

        @media << "a=setup:passive" # can be setup:active setup:passive setup:actpass or setup:holdconn
        # obtained via
        # openssl x509 -in server-cert.pem -sha1 -noout -fingerprint
        @media << "a=fingerprint:sha-1 4E:D9:E7:BD:AA:E3:F6:C8:A0:4B:E8:D6:C7:74:88:33:53:31:EE:76"
        @media << "a=ice-lite"
        @media << "a=rtcp-mux"
        @media << "a=ice-ufrag:#{srv_ufrag}"
        @media << "a=ice-pwd:#{srv_upass}"
        @media << "a=candidate:0 1 udp 2130706431 #{srv_ip} #{rtp_port} typ host"  # rtp
        @media << "a=candidate:0 2 udp 2130706430 #{srv_ip} #{rtcp_port} typ host" # rtcp
      end
    end

    def body
      String.build do |str|
        @session.each do |k, v|
          str << k << "=" << v << "\r\n"
        end
        @time.each do |k, v|
          str << k << "=" << v << "\r\n"
        end
        @media.each do |s|
          str << s << "\r\n"
        end
      end
    end
  end
end
