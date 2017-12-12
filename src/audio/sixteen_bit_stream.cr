module Audio
  class SixteenBitStream < Stream
    BITDEPTH          =    16        # 16-bit audio
    SAMPLE_RATE       = 48000        # 48 khz audio
    PACKET_HZ         =    50        # 50hz = 20ms intervals between packets # TODO this should be parameterized
    BYTES_PER_SAMPLE  = BITDEPTH / 8 # 8 bits per byte
    SAMPLES_PER_FRAME = SAMPLE_RATE / PACKET_HZ

    getter audio_size

    @audio : Slice(Int16)
    @position = 0

    def initialize(data : Slice(Int16))
      @audio = data
    end

    def initialize(path : String)
      audio_path = path
      audio_size = File.size(audio_path)
      audio_bytes = Bytes.new(audio_size)

      File.open(audio_path, "r") do |f|
        f.read_fully(audio_bytes)
      end

      audio_ptr = audio_bytes.to_unsafe.as(Int16*)
      pad_audio_size = audio_size / BYTES_PER_SAMPLE
      puts "Audio size is (non-pad): #{pad_audio_size}"
      remain = pad_audio_size % SAMPLES_PER_FRAME
      if remain != 0
        pad_audio_size += SAMPLES_PER_FRAME - remain
      end
      puts "Audio size is (w pad): #{pad_audio_size}"

      @audio = audio_ptr.to_slice(pad_audio_size)
    end

    # def initialize
    #   the_future = Watson::TTS.new
    #   @audio_buff = the_future.synthesize("I'm a cat! I'm a big big big cat.")
    #   @audio_slices = @audio_buff.size / PACKET_BYTES
    #   # TODO we should pad out the audio to be a multiple of RTP_SIZE
    # end

    def _next : Slice(Int16)?
      if @position >= @audio.size
        return nil
      else
        remain = @audio.size - @position
        grab = [SAMPLES_PER_FRAME, remain].min
        payload = @audio[@position, grab]
        @position += grab
        return payload
      end
    end

    def payload_interval : Float64
      1.0 / PACKET_HZ
    end
  end
end
