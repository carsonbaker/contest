module Codec
  
  class Generic
  
    def encode(audio : Slice(Int16)) : Bytes
      raise "to be implemented by subclass..."
    end
    
    def decode(data : Bytes) : Slice(Int16)
      raise "to be implemented by subclass..."
    end
    
    def samples_per_frame : Int32
      raise "to be implemented by subclass..."
    end
  
  end
  
end