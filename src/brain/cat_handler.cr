# require "./handler"
require "../audio/stream"
require "../audio/sixteen_bit_stream"

module Brain
  
  class CatHandler < Handler
    
    @stream : Audio::Stream
    
    def initialize(@call)
      super(@call)
      @stream = Audio::SixteenBitStream.new("audio/speech_orig_16.pcm")
    end

    def receive_audio(audio : Bytes)
      puts "--------- #receive_rtp"
    end
    
    def end_call
      puts "--------- #end_call"
    end
    
    def next_audio_frame : Slice(Int16)?
      return @stream.next()
    end
    
    def audio_interval : Number
      return @stream.payload_interval
    end
    
    def start_call
      puts "--------- #start_call"
    end

  end
  
end