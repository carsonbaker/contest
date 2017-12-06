require "./call"

module Graph

  class Collection

    @@calls = [] of Call

    def self.add(a)
      @@calls.push(a)
      return a
    end
    
    def self.find_by_username(username : String)
      @@calls.find { |s| s.formed_username == username }
    end
    
    def self.find_by_call_id(call_id : String)
      @@calls.find { |s| s.call_id == call_id }
    end
    
    def self.remove(c : Call)
      L.info "[ Removing #{c.call_id} ]"
      @@calls.delete(c)
    end
    
    # def self.remove_by_callid(call_id : String)
    #   index = @@calls.index { |s| s.call_id == call_id }
    #   @@calls.delete(index)
    # end
    
  end
  
end