require "./generic"
require "../../src/samplerate/lib"

module Codec
  
  class MuLaw < Generic
    
    FRAME_SIZE  = 160 # equals 50 frames per second at 8khz (20ms intervals)
    
    CBIAS =  0x84_u16
    CCLIP = 32635_u16

    EXP_LUT = [0,132,396,924,1980,4092,8316,16764]
    TABLE = Pointer(UInt8).malloc(UInt8::MAX)

    (0..1).each { |a| TABLE[a] = 0_u8 }
    (2..3).each { |a| TABLE[a] = 1_u8 }
    (4..7).each { |a| TABLE[a] = 2_u8 }
    (8..15).each { |a| TABLE[a] = 3_u8 }
    (16..31).each { |a| TABLE[a] = 4_u8 }
    (32..63).each { |a| TABLE[a] = 5_u8 }
    (64..127).each { |a| TABLE[a] = 6_u8 }
    (128..255).each { |a| TABLE[a] = 7_u8 }
    
    def initialize
      super()
    end
    
    # From 48khz to 8khz
    def downsample_best(pcm : Slice(Int16)) : Slice(Int16)
      # first convert int16 to float
      audio = Slice(Float32).new(pcm.size)
      pcm.each_with_index do |sample, i|
        audio[i] = sample.to_f32 / Int16::MAX
      end
      
      auout = Slice(Float32).new(pcm.size / 6)
  
      sd = LibSampleRate::Src_data.new
      sd.data_in = audio.to_unsafe
      sd.data_out = auout.to_unsafe
      
      sd.input_frames = audio.size
      sd.output_frames = auout.size
          
      sd.src_ratio = Float64.new(auout.size) / Float64.new(audio.size)
      
      conv_type = LibSampleRate::ConverterType::SRC_SINC_BEST_QUALITY
      channels = 1
          
      err = LibSampleRate.src_simple(pointerof(sd), conv_type, channels)
      if err != 0
        err_str = String.new(LibSampleRate.src_strerror(err))
        raise "Could not downsample audio: #{err_str}"
      end
      
      # convert back to int16
      result = Slice(Int16).new(auout.size)
      auout.each_with_index do |sample, i|
        result[i] = (sample * Int16::MAX).to_i16
      end
      
      return result
    end
    
    def downsample_fast(pcm : Slice(Int16)) : Slice(Int16)
      da_new = Slice(Int16).new(pcm.size / 6)
      i = 0
      while(i < pcm.size - 6)
        da_new[i / 6] = pcm[i] + pcm[i+1] + pcm[i+2] + pcm[i+3] + pcm[i+4] + pcm[i+5]
        i += 6
      end
      return da_new
    end
    
    def samples_per_frame
      return FRAME_SIZE
    end
    
    def decode(encoded : Bytes) : Slice(Int16)
      pcm = Slice(Int16).new(encoded.size)
      0.upto(encoded.size-1) do |a|
        pcm[a] = decode_sample(encoded[a])
      end
      return pcm
    end
  
    def decode_sample(ulawbyte : UInt8) : Int16
      ulawbyte = ~ulawbyte
      sign     = ulawbyte & 0x80
      exponent = (ulawbyte >> 4) & 0x07
      mantissa = ulawbyte & 0x0f
      sample = Int16.new(EXP_LUT[exponent] + (mantissa << (exponent + 3)))
      return sign != 0 ? -sample : sample
    end
  
    def encode(pcm : Slice(Int16)) : Bytes
      pcm = downsample_best(pcm)
      encoded = Bytes.new(pcm.size)
      0.upto(pcm.size-1) do |a|
        encoded[a] = encode_sample(pcm[a])
      end
      return encoded
    end
    
    def encode_sample(sample : Int16) : UInt8
      # get the sample into sign-magnitude
      sign = (sample >> 8) & 0x80 # set aside the sign

      sample = -sample if sign != 0 # get magnitude
      sample = CCLIP if sample > CCLIP # clip the magnitude
      sample += CBIAS
      
      exponent = UInt8.new(TABLE[(sample >> 7) & 0xFF])
      mantissa = UInt8.new((sample >> (exponent + 3)) & 0x0F)
      return UInt8.new(~(sign | (exponent << 4) | mantissa))
    end
    
  end
  
end