require "spec"
require "../../src/opus/encoder"

describe Opus::Encoder do
  
  # it "does what it's supposed to do" do
  #   application = LibOpus::OPUS_APPLICATION_VOIP
  #   sample_rate = 48000
  #   channels = 2
  #   frame_size = 960
  #   bitrate = 64000
  #   audio = File.read("audio/speech_orig.wav")
  #   
  #   encoder = LibOpus.opus_encoder_create(sample_rate, channels, application, out err)
  #   err.should eq(0)
  #   
  #   LibOpus.opus_encoder_ctl(encoder, bitrate)
  # end
  
  it "asdf" do
    # Set up encoder
    sample_rate = 48000
    channels    = 2
    frame_size  = 960 # equals 50 frames per second
    encoder = Opus::Encoder.new(sample_rate, frame_size, channels)
    encoder.bitrate = 64000
    
    # Read some audio
    # 
    # audio_path = "audio/speech_orig.wav"
    # audio_size = File.size(audio_path)
    # audio_buff = Bytes.new(audio_size)
    # 
    # File.open(audio_path, "r") do |f|
    #   f.read_fully(audio_buff)
    # end
    # 
    # audio_ptr = audio_buff.to_unsafe.as(Int16*)
    # slice_size = audio_size / 2
    # audio = audio_ptr.to_slice(slice_size)
    # 
    # i = 0
    # # File.open("audio/speech_opus.opus", "w") do |f|
    #   while(i < slice_size)
    #     room = [50, slice_size - i].min
    #     frame = audio[i, room]
    #   
    #     # Encode audio
    #     opus_bytes = encoder.encode_frame(frame)
    #     
    #     f.write(opus_bytes)
    #     i += frame_size
    #   end
    # # end

  end

end
