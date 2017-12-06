require "./sixteen_bit_stream"
require "../watson/tts"

module Audio

  class WatsonStream < SixteenBitStream
    
    def initialize(text : String)
      # TODO - cache this
      tts = Watson::TTS.new
      audio_bytes = tts.synthesize(text)
      
      audio_ptr = audio_bytes.to_unsafe.as(Int16*)
      audio = audio_ptr.to_slice(audio_bytes.size / 2)
    
      super(audio)
    end
    
  end
  
end