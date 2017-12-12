require "../logger"
require "../graph/collection"
require "./first_flurry"
require "./msg"
require "../transport/rtp"
require "../codec/opus"
require "../codec/mu_law"

module SIP
  class Session
    def initialize(interface_addr : Socket::IPAddress)
      @sip_socket = UDPSocket.new
      @sip_socket.bind(interface_addr)
    end

    def finalize
      @sip_socket.close
    end

    def self.start_track_sip_conv(sip_msg, transport)
      call = Graph::Call.new do |c|
        c.handler = Brain::VoicemailHandler.new(transport)
        c.to = sip_msg.sip_header.request_uri
        c.call_id = sip_msg.sip_header.call_id
        c.server_userfrag = random_str = (0...16).map { ('a'..'z').to_a[rand(26)] }.join
        c.server_password = random_str = (0...22).map { ('a'..'z').to_a[rand(26)] }.join
        c.client_userfrag = sip_msg.sdp_header.ice_userfrag
        c.client_password = sip_msg.sdp_header.ice_password
        # c.client_addr     = client_addr
      end
      return Graph::Collection.add(call)
    end

    def handle_invite(sip_msg : SIP::Msg, client_addr : Socket::IPAddress)
      call_id = sip_msg.sip_header.call_id
      L.info " [ New SIP conversation: (Call ID: #{call_id})]"
      existing_call = Graph::Collection.find_by_call_id(call_id)

      # There's already a SIP conversation initiated with this Call ID!
      # Let's just ignore this duplicate INVITE...
      return if existing_call

      # Set up transport
      opus_port = sip_msg.sdp_header.rtp_map["opus/48000/2"]?
      transport = opus_port ? Transport::RTP.new(Codec::Opus.new, opus_port) : Transport::RTP.new(Codec::MuLaw.new, 0)
      transport.client_addr = Socket::IPAddress.new(client_addr.address, sip_msg.sdp_header.media_port)

      # Start tracking this as a new session
      call = SIP::Session.start_track_sip_conv(sip_msg, transport)

      top_via_info = sip_msg.sip_header.top_via_info

      # Just checking to see what we see in the SDP header
      if sip_msg.sdp_header.has_rtcp_info?
        rtcp_conn_info = sip_msg.sdp_header.rtcp_connect_addr_and_port
        L.info "SDP header: connect to media on port #{sip_msg.sdp_header.media_port}"
        L.info "SDP header: connect to rtcp on #{rtcp_conn_info[:host]} with port #{rtcp_conn_info[:port]}"
      end

      sip_cmd_reply_host = top_via_info[:host]
      sip_cmd_reply_port = top_via_info[:port] || Conf::DEFAULT_SIP_PORT
      reply_addr = Socket::IPAddress.new(sip_cmd_reply_host, sip_cmd_reply_port)

      if client_addr.address != reply_addr.address
        L.warn "Client address (#{client_addr}) does not match reply address (#{reply_addr})"
      end

      send_proc = ->(str : String) {
        puts "\n\nSending reply to #{client_addr}:\n#{str}"
        @sip_socket.send(str, client_addr)
      }
      reply = SIP::FirstFlurry.new(sip_msg, false, call) # false value indicates normal transport (not websocket)
      reply.transmit(send_proc)

      spawn {
        begin
          call.handler.listen
        rescue IO::Timeout
          call.destroy
        end
      }
      # Tell the call handler that the call has begun
      call.handler.queue_event(:start_call)
    end

    def handle_ack(sip_msg, client_addr)
    end

    def handle_bye(sip_msg, client_addr)
      call_id = sip_msg.sip_header.call_id
      call = Graph::Collection.find_by_call_id(call_id)
      send_proc = ->(str : String) { @sip_socket.send(str, client_addr) }
      if call
        call.responder.reset_c_seq(sip_msg.sip_header.cseq)
        begin
          L.info " --> Sending SIP 200 OK (in reply to BYE)"
          ok_response = call.responder.generate(ResponseCmd::OK)
          send_proc.call(ok_response)
          puts ok_response
        rescue ex : Errno
          if ex.errno == Errno::ECONNREFUSED
            p ex.inspect
          end
        end

        call.destroy
      end
    end

    def handle_cancel(sip_msg, client_addr)
      L.warn "Don't know how to handle CANCEL" # TODO
    end

    def handle_update(sip_msg, client_addr)
      L.warn "Don't know how to handle UPDATE" # TODO
    end

    def handle_sip_event(data, client_addr)
      begin
        sip_msg = SIP::Msg.new(data)
        L.info " <-- Received SIP #{sip_msg.sip_header.command}"

        if sip_msg.sip_header.command == "INVITE"
          handle_invite(sip_msg, client_addr)
        elsif sip_msg.sip_header.command == "ACK"
          handle_ack(sip_msg, client_addr)
        elsif sip_msg.sip_header.command == "UPDATE"
          handle_update(sip_msg, client_addr)
        elsif sip_msg.sip_header.command == "CANCEL"
          handle_cancel(sip_msg, client_addr)
        elsif sip_msg.sip_header.command == "BYE"
          handle_bye(sip_msg, client_addr)
        else
          L.warn "Unhandled SIP command (#{sip_msg.sip_header.command}"
          return
        end
      rescue e
        L.error(e.inspect_with_backtrace)
        return
      end
    end

    def run
      loop do
        data, client_addr = @sip_socket.receive(2000) # TODO -- how long should this be
        handle_sip_event(data, client_addr)
      end
    end
  end
end
