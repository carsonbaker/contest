module Transport
  class Debug < Generic
    def initialize
      super(Codec::MuLaw.new, 0)
    end

    def _send_audio(rtp_data : Bytes)
      puts "[DebugTransport] _send_audio"
    end

    def process(data : Bytes, addr : Socket::IPAddress)
      puts "[DebugTransport] process"
    end
  end
end
