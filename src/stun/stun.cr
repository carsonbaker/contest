require "../graph/collection"
require "./conv"

module Stun

  def self.handle_stun_payload(payload : Bytes, addr : Socket::IPAddress, sock : Socket)
    stun_conv = Stun::Conv.new(payload, addr)
    
    if username = stun_conv.username
      state = Graph::Collection.find_by_username(username.not_nil!)
      stun_conv.password = state.server_password if state
    end
    reply = stun_conv.reply
    
    sock.send(reply, addr)
    puts "Sent STUN reply (#{reply.size}) to #{addr}"
  end    
  
end
