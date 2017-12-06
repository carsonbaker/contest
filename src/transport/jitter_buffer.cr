
module Transport
  class JitterBuffer
    
    @buffer : Array({ Int32, Bytes })
    
    def on_pump(&block : Bytes -> )
      @on_pump_callback = block
    end
    
    def initialize(@room = 5) # 100ms initial value
      @buffer = Array({ Int32, Bytes }).new(@room)
    end
    
    def feed(data : Bytes, seq_no : Int32)
      @buffer.push({ seq_no, data })
      check
      @buffer.sort { |uno, dos| uno[0] <=> dos[0] }
      
      if callback = @on_pump_callback
        if something_to_pump = pull
          callback.call(something_to_pump)
        end
      end
    end
    
    def check
      order = @buffer[0][0]
      @buffer[1,@buffer.size-1].each do |a|
        if a[0] != order + 1
          the_order = @buffer.map { |b| b[0] }
          puts "Out of sync: #{the_order}"
          break
        end
        order = a[0]
      end
    end
    
    def ready
      # TODO - this should return true if a certain timeout has passed too
      @buffer.size > @room
    end
    
    def pull : Bytes?
      if ready
        return @buffer.shift[1]
      end
    end
    
  end
end
