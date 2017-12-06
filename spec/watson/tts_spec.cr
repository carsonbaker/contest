require "spec"
require "../src/watson/tts"

describe Watson::TTS do
  
  it "should convert some text to some speech" do
    tts = Watson::TTS.new
    wav = tts.synthesize("Hi")
    
    wav.should be_truthy
  end

end
