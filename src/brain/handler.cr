require "../util/timer"
require "../transport/generic"

module Brain
  abstract class Handler
    # receive raw or pcma audio
    # receive dtmf tones
    # synthesize tts audio pcma

    @incoming_media = Channel(Slice(Int16)).new
    @action_pipe = Channel(Symbol).new
    @transport : Transport::Generic

    getter transport : Transport::Generic

    def initialize(@transport : Transport::Generic)
      @shutdown = false

      # One fiber to process events
      spawn do
        loop do
          action = @action_pipe.receive
          case action
          when :start_call
            start_call
            schedule_audio
          when :end_call
            end_call
            @shutdown = true
            break
          when :dtmf
            # not implemented
          end
        end
      end

      # One fiber to receive audio
      spawn do
        loop do
          break if @shutdown
          buffer = @incoming_media.receive
          receive_audio(buffer)
        end
      end
    end

    def queue_event(event : Symbol)
      @action_pipe.send(event)
    end

    def queue_incoming_media(buffer : Slice(Int16))
      @incoming_media.send(buffer)
    end

    def audio_interval : Number
      # to be implemented by subclasses
    end

    def receive_audio(audio : Slice(Int16))
      # to be implemented by subclasses
    end

    def start_call
      # to be implemented by subclasses
    end

    def end_call
      # to be implemented by subclasses
    end

    def listen
      @transport.listen
    end

    def finalize
      @transport.finalize
    end

    def next_audio_frame(millisecs : Int64) : Slice(Int16)?
      # to be implemented by subclasses
      raise "#next_audio_frame needs to be implemented by subclass."
    end

    private def schedule_audio
      t = Util::Timer.new(audio_interval)

      t.fire do |tick|
        audio_data = next_audio_frame(tick / 10000)
        if audio_data
          @transport.send_audio(audio_data)
        else
          @transport.observe_silence
          # t.cancel
        end
      end
    end
  end
end
