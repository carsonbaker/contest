# require "./handler"
require "../audio/stream"
require "../audio/watson_stream"
require "../watson/tts"

module Brain
  class VoicemailHandler < Handler
    @prompt : Audio::Stream

    def initialize(transport : Transport::Generic)
      super(transport)
      @cough = File.open("cough.raw", "w")

      prompt_text = "Please leave a message at the beep."
      @prompt = Audio::WatsonStream.new(prompt_text)
      # @prompt.on_complete { puts "onComplete called!" }
    end

    def receive_audio(audio : Slice(Int16))
      # puts "--------- #receive_rtp in voicemail_handler"
      puts "Got #{audio.size} bytes of audio"
      audio_ptr = audio.to_unsafe.as(UInt8*)
      slice_size = audio.size * 2
      outsky = audio_ptr.to_slice(slice_size)
      @cough.write(outsky)
    end

    def end_call
      puts "--------- #end_call"
    end

    def next_audio_frame(millisecs : Int64) : Slice(Int16)?
      if millisecs < 250
        # Silence for a quarter of a second after the call answers
        return nil
      end
      return @prompt.next
    end

    def audio_interval : Number
      return @prompt.payload_interval
    end

    def start_call
      puts "--------- #start_call"
    end
  end
end
