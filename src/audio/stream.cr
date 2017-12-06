module Audio

  abstract class Stream
  
    @on_complete_callback_called = false

    def on_complete(&block)
      @on_complete_callback = block
    end

    def next : Slice(Int16)?
      ret = _next()
      if ret
        return ret
      else
        if !@on_complete_callback_called
          if callback = @on_complete_callback
            callback.call
            @on_complete_callback_called = true
          end
        end
        return nil
      end
    end

    def _next : Slice(Int16)?
      raise "Needs to be implemented by subclass"
    end
    
    def payload_interval : Float64
      raise "Needs to be implemented by subclass"
    end
    
  end
  
end