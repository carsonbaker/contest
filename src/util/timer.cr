module Util
  class Timer
    
    @tick_interval : Float64
    TPS_FLOAT_64 = Float64.new(Time::Span::TicksPerSecond)
    
    def initialize(@seconds : Float64)
      @canceled = false
      @tick_interval = @seconds * Time::Span::TicksPerSecond
      raise ArgumentError.new "sleep seconds must be positive" if @seconds < 0
    end
    
    def cancel
      @canceled = true
    end
    
    def fire(&block : Int64 -> ) # sleeps first and then fires
      
      start_ticks = Time.local_ticks
      should_tick = 0
      
      # FIXME - I'm a little worried about overflow conditions here..
      # what happens when tick_d grows to a very big number?
      
      spawn do
        loop do
          
          tick_d     = Time.local_ticks - start_ticks
          drift      = should_tick - tick_d  
          drift_sec  = drift / TPS_FLOAT_64  
          correction = @seconds + drift_sec
          
          sleep(correction) if correction > 0

          break if @canceled
          block.call(tick_d)
          should_tick += @tick_interval
        end
      end
    end
    
  end
end