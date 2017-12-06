require "../opus/encoder"

module Codec
  
  class Opus < Generic
    
    SAMPLE_RATE = 48000
    FRAME_SIZE  = 960 # equals 50 frames per second at 48khz
    CHANNELS    = 1
    INTERVAL    = FRAME_SIZE.to_f / SAMPLE_RATE.to_f
    
    @encoder    : ::Opus::Encoder

    def samples_per_frame
      return FRAME_SIZE
    end

    def initialize      
      @encoder = ::Opus::Encoder.new(SAMPLE_RATE, FRAME_SIZE, CHANNELS)
      @encoder.bitrate = 64000
    end
    
    def encode(audio : Slice(Int16)) : Bytes
      @encoder.encode_frame(audio)
    end
    
    # def next : Bytes?     
    #   remaining = @audio.size - @position 
    #   return nil if remaining < 0      
    #   frame_width = [remaining, 50].min
    #   frame = @audio[@position, frame_width]
    #   @position += frame_width
    #   bytes = @encoder.encode_frame(frame)
    #   puts "Byte count is #{bytes.size}"
    #   return bytes
    # end
    # 

  end
  
end