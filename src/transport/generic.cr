require "../codec/generic"
require "./jitter_buffer"
require "../util/conf"

module Transport
  abstract class Generic
    property! client_addr : Socket::IPAddress?
    getter rtp_port : Int32
    getter rtp_socket : UDPSocket
    # getter rtcp_socket                   : Socket

    @seq_no = 0
    @@used_rtp_ports = [] of Int32

    def handle_rtp(payload : Bytes)
      header_size = 12
      header = payload[0, header_size]
      seq_no = IO::ByteFormat::NetworkEndian.decode(UInt16, header[2, 2]).to_i32 # 2 bytes
      @jitter_buffer.feed(payload[header_size, payload.size - header_size], seq_no)
    end

    def form_rtp(payload : Bytes) : Bytes
      data = Bytes.new(payload.size + 12)

      # ##  Details on RTP headers are here:
      # ## https://en.wikipedia.org/wiki/Real-time_Transport_Protocol

      # first byte is 0x80.. this says we're using rfc 1889 version 2
      # second byte is 0x00.. this is the rtp payload type for g.711 pcma mu-law
      data[0] = 0x80_u8
      data[1] = @media_profile_pt.to_u8

      if (@seq_no == 1)
        data[1] = data[1] | 0x80_u8 # 0x80 sets the marker bit
      end

      # then comes two bytes for the sequence number
      data[2] = UInt8.new((@seq_no & 0xff00) >> 8)
      data[3] = UInt8.new((@seq_no & 0x00ff))

      # then comes 4 bytes for the timestamp
      timestamp = @seq_no * @encoder.samples_per_frame

      data[4] = UInt8.new((timestamp & 0xff000000) >> 24)
      data[5] = UInt8.new((timestamp & 0x00ff0000) >> 16)
      data[6] = UInt8.new((timestamp & 0x0000ff00) >> 8)
      data[7] = UInt8.new((timestamp & 0x000000ff))

      # then comes 4 bytes for the syncronization source identifier
      data[8] = 0x01_u8
      data[9] = 0x02_u8
      data[10] = 0x03_u8
      data[11] = 0x04_u8

      # the rtp header takes 12 bytes so that leaves us with 160 bytes left for data
      payload_point = data + 12
      payload.copy_to(payload_point)

      return data
    end

    def self.alloc_random_rtp_port : Int32
      rtp_port_range = Conf::RTP_PORT_RANGE

      p = rand(rtp_port_range) & ~1 # ensures an even number
      if @@used_rtp_ports.includes? p
        return self.alloc_random_rtp_port
      else
        @@used_rtp_ports.push(p)
        return p
      end
    end

    def initialize(@encoder : Codec::Generic, @media_profile_pt : Int32)
      @rtp_port = Generic.alloc_random_rtp_port
      @teardown = false

      @jitter_buffer = JitterBuffer.new
      @jitter_buffer.on_pump { |data|
        # decode it
        raw = @encoder.decode(data)
      # TODO -- fix! fix! fix ! @call.handler.queue_incoming_media(raw)
      }

      @rtp_socket = UDPSocket.new
      @rtp_socket.reuse_address = true
      @rtp_socket.reuse_port = true
      @rtp_socket.read_timeout = 5
      @rtp_socket.bind(Conf::SERVER_LISTEN_ADDRESS, @rtp_port)

      L.clue "#{self.class} listening for UDP on port #{@rtp_port}..."
    end

    def listen
      # can throw a IO::Timeout
      while (!@teardown)
        data = Bytes.new(1024)
        begin
          byte_count, address = @rtp_socket.receive(data)
          # @client_addr ||= Socket::IPAddress.new(address.address, 34620)
          @client_addr = address
          data = data[0, byte_count]
          process(data, address)
        rescue errno : Errno
          L.error errno
        end
      end
    end

    def process(data : Bytes, addr : Socket::IPAddress)
      # To be implemented by subclasses
    end

    def send_audio(audio : Slice(Int16))
      inc_seq_no
      rtp_data = encode_and_rtp(audio)
      _send_audio(rtp_data)
    end

    def observe_silence
      inc_seq_no
    end

    def _send_audio(rtp_data : Bytes)
      # To be implemented by subclasses
    end

    def inc_seq_no
      @seq_no += 1
    end

    def encode_and_rtp(audio : Slice(Int16)) : Bytes
      encoded_audio = @encoder.encode(audio)
      return form_rtp(encoded_audio)
    end

    def finalize
      @teardown = true
      @@used_rtp_ports.delete(@rtp_port)
    end
  end
end
