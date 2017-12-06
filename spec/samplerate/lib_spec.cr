require "spec"
require "../../src/samplerate/lib"

describe "LibSampleRate" do
  
  it "downsamples audio" do

    audio = Slice(Float32).new(16)
    audio[0] = 0.0_f32
    audio[1] = 0.25_f32
    audio[2] = 0.5_f32
    audio[3] = 0.75_f32
    audio[4] = 1.0_f32
    audio[5] = 0.75_f32
    audio[6] = 0.5_f32
    audio[7] = 0.25_f32
    audio[8] = 0.0_f32
    audio[9] = -0.25_f32
    audio[10] = -0.5_f32
    audio[11] = -0.75_f32
    audio[12] = -1.0_f32
    audio[13] = -0.75_f32
    audio[14] = -0.5_f32
    audio[15] = -0.25_f32
    audio[15] = 0.0_f32

    auout = Slice(Float32).new(audio.size * 2)
    
    sd = LibSampleRate::Src_data.new
    sd.data_in = audio.to_unsafe
    sd.data_out = auout.to_unsafe
    
    sd.input_frames = audio.size
    sd.output_frames = auout.size
    
    sd.src_ratio = 2
    
    conv_type = LibSampleRate::ConverterType::SRC_SINC_BEST_QUALITY
    channels = 1
    
    err = LibSampleRate.src_simple(pointerof(sd), conv_type, channels)
    
    err.should eq(0)

  end

end
