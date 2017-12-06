require "./lib"

module Opus
  class Encoder
    
    @sample_rate : Int32
    @frame_size : Int32
    @channels : Int32

    def initialize(@sample_rate, @frame_size, @channels)
      @encoder = LibOpus.opus_encoder_create(@sample_rate, @channels, LibOpus::OPUS_APPLICATION_VOIP, out err)
      raise "Could not initialize Opus encoder" if err < 0
    end

    def finalize
      LibOpus.opus_encoder_destroy(@encoder)
    end

    # def reset
    #   LibOpus.opus_encoder_ctl(@encoder, LibOpus::OPUS_RESET_STATE, :pointer, nil
    # end

    def vbr_rate=(value : Int32)
      LibOpus.opus_encoder_ctl(@encoder, LibOpus::OPUS_SET_VBR_REQUEST, value)
    end

    def bitrate=(value : Int32)
      LibOpus.opus_encoder_ctl(@encoder, LibOpus::OPUS_SET_BITRATE_REQUEST, value)
    end

    def encode_frame(audio : Slice(Int16)) : Bytes
      max_packet_size = 1276 # recommended in LibOpus docs
      out_data = Bytes.new(max_packet_size)
      len = LibOpus.opus_encode(@encoder, audio, @frame_size, out_data, max_packet_size)
      return out_data[0, len]
    end
  end
end