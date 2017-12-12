require "socket"
require "./lib"
require "../logger"
require "../stun/stun"

module DTLSSRTP
  
  class SSLContext
    
    getter context
    getter dsink

    INSTANCE = new
    
    TLS_CERT_PATH  = "certs/server-cert.pem"
    TLS_KEY_PATH   = "certs/server-key.pem"
    RTP_PACKET_LEN = 1000
    
    @context : OpenSSL::SSL::Context::Server
    @dsink : LibDTLSSRTP::Dsink
    
    def self.get_context : OpenSSL::SSL::Context::Server
      INSTANCE.context
    end
    
    def self.get_dsink : LibDTLSSRTP::Dsink
      INSTANCE.dsink
    end
    
    def initialize

      @context = OpenSSL::SSL::Context::Server.new(LibSSL.dtls_server_method) # dtls_server_method in new versions of OpenSSL
      @context.private_key       = TLS_KEY_PATH
      @context.certificate_chain = TLS_CERT_PATH

      # TODO - Should check that this certificate matches the one presented in the SDP
      verify_peer = ->(ok : Int32, ctx : LibCrypto::X509_STORE_CTX) { return 1 }

      LibSSL.ssl_ctx_set_verify(@context, OpenSSL::SSL::VerifyMode::PEER, verify_peer)
      
      # TODO - I'm not sure when to use one or the other here...
      LibSSL.ssl_ctx_set_tlsext_use_srtp(@context, "SRTP_AES128_CM_SHA1_80")
      # LibSSL.ssl_ctx_set_tlsext_use_srtp(@@context, "SRTP_AES128_CM_SHA1_32") 
      
      # verify_mode = LibDTLSSRTP::Dtls_verify_mode::DTLS_VERIFY_FINGERPRINT
      # @cfg = LibDTLSSRTP.dtls_ctx_init(verify_mode, nil, pointerof(cfg));
      
      @dsink = LibDTLSSRTP::Dsink.new
      @dsink.name = "dsink_udp"
      @dsink.sendto = -> (carrier : Int32, data : Void*, datalen : Int32, flags : Int32, target : LibC::Sockaddr*, tglen : LibC::SocklenT) {
        LibC.sendto(carrier, data, datalen, flags, target, tglen)
      }
      @dsink.sched = nil

    end
  
  end

end

    
