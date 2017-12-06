
module Transport
  class RTP < Generic
    
    def _send_audio(rtp_data : Bytes)
      unless @rtp_socket.closed?
        # puts "*** Sending RTP #{rtp_data.size} bytes to #{client_addr}"
        @rtp_socket.send(rtp_data, client_addr)
      end
    end
    
    def process(data : Bytes, addr : Socket::IPAddress)
      handle_rtp(data)
    end

  end
  
end
