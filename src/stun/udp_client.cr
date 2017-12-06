require "socket"
require "openssl"
require "./header.cr"

module Stun
    
  class UDPClient

    def initialize(@addr : Socket::IPAddress)
      @client = UDPSocket.new(@addr.family)
      @client.connect(@addr.address, @addr.port)
    end
    
    def transmit_binding_request
      @client.write(StunHeader.new.serialize.to_slice)
    end
    
    def close
      @client.close
    end

  end
  
end