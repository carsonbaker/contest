require "../dtlssrtp/lib"
require "../dtlssrtp/ssl_context"
require "../stun/stun"

module Transport
  class SRTP < Generic
    RTP_PACKET_LEN = 1000

    @srtp_incoming : LibSRTPDecrypt::Srtp_session_ptr?
    @srtp_outgoing : LibSRTPDecrypt::Srtp_session_ptr?

    @dtls : LibDTLSSRTP::Dtls_sess*

    @ssl_ctx = DTLSSRTP::SSLContext.get_context
    @dsink = DTLSSRTP::SSLContext.get_dsink

    def initialize(@call : Graph::Call, @encoder : Codec::Generic, @media_profile_pt : Int32)
      @dtls = LibDTLSSRTP.dtls_sess_new(@ssl_ctx, pointerof(@dsink), LibDTLSSRTP::Dtls_con_state::DTLS_CONSTATE_PASS)
      super(@call, @encoder, @media_profile_pt)
    end

    def process(payload : Bytes, addr : Socket::IPAddress?)
      # TODO need to call this when we're done
      # LibDTLSSRTP.dtls_sess_free(dtls) if dtls

      if (payload[0] == 0) || (payload[0] == 1)
        L.debug "<-- STUN datagram (#{payload.size} bytes)"
        Stun.handle_stun_payload(payload, addr, @rtp_socket)
      end

      if (payload[0] >= 128) && (payload[0] <= 191)
        L.debug "<-- SRTP datagram (#{payload.size} bytes)"
        handle_srtp(payload)
      end

      if (payload[0] >= 20) && (payload[0] <= 64)
        L.debug "<-- DTLS datagram (#{payload.size} bytes)"
        handle_dtls(payload, @rtp_socket, addr, @call)
      end
    end

    def send_audio(rtp_data : Bytes)
      return if !@srtp_outgoing         # must wait until DTLS is established
      b = Bytes.new(rtp_data.size + 64) # increases room by tagsize = 10
      b.copy_from(rtp_data)
      len = rtp_data.size.to_u64
      ret = LibSRTPDecrypt.srtp_send(@srtp_outgoing, b, pointerof(len), b.size)
      L.error "Could not send SRTP payload (ret == #{ret})" if ret != 0
      b = b[0, len]

      if client_addr
        @rtp_socket.send(b, client_addr)
      else
        raise "Haven't yet chosen client candidate."
      end
    end

    def handle_srtp(payload : Bytes)
      return if payload[1] == 0xc8 # indicates RTCP sender report
      len = payload.size.to_u64
      ret = LibSRTPDecrypt.srtp_recv(@srtp_incoming, payload, pointerof(len))
      L.error "SRTP payload could not be received (ret == #{ret})" if ret != 0
      handle_rtp(payload)
    end

    def handle_dtls(payload : Bytes, sock : UDPSocket, client_addr : Socket::IPAddress, call : Graph::Call)
      len = LibDTLSSRTP.dtls_sess_put_packet(
        @dtls,
        sock.fd,
        payload,
        payload.size,
        client_addr.to_unsafe,
        client_addr.size
      )

      if len < 0
        err = LibSSL.ssl_get_error(@dtls.value.ssl, len)
        if !err.want_read?
          raise OpenSSL::SSL::Error.new(@dtls.value.ssl, len, "SSL_read")
        end
      end

      if @dtls.value.type == LibDTLSSRTP::Dtls_con_type::DTLS_CONTYPE_EXISTING
        peer_cert_x509_ptr = LibSSL.ssl_get_peer_certificate(@dtls.value.ssl)
        peer_cert = peer_cert_x509_ptr.try do |crt|
          OpenSSL::X509::Certificate.new(crt)
        end
        # puts "Peer cert is #{peer_cert}"

        fingerprint = Bytes.new(256)
        ret = LibCrypto.x509_digest(peer_cert_x509_ptr, LibCrypto.evp_sha256, fingerprint, out size)
        fingerprint = fingerprint[0, size]
        # puts "x509 digest is #{ret}"
        # raise "Could not determine fingerprint of peer cert." if ret < 0
        # puts "\n---------------------------------------"
        # puts "Fingerprint is SHA-256 #{fingerprint.hexstring}"
        # # puts "Fingerprint is SHA-1 #{fingerprint.hexstring}"
        # puts "---------------------------------------\n"
        #
        key_material = LibDTLSSRTP.srtp_get_key_material(@dtls)
        key_slice = key_material.value.material.to_slice.clone

        scmk = key_slice[0, 16]  # srtp client master key
        scs = key_slice[32, 14]  # srtp client salt
        ssmk = key_slice[16, 16] # srtp server master key
        sss = key_slice[46, 14]  # srtp server salt

        LibDTLSSRTP.key_material_free(key_material)
        LibDTLSSRTP.dtls_sess_free(@dtls) # we done. we out.

        L.info "** DTLS established **"

        # Create SRTP policies

        taglen = 10

        @srtp_outgoing = LibSRTPDecrypt.srtp_create(LibSRTPDecrypt::SRTP_ENCR_AES_CM, LibSRTPDecrypt::SRTP_AUTH_HMAC_SHA1, taglen, LibSRTPDecrypt::SRTP_PRF_AES_CM, 0)
        raise "Could not create outgoing SRTP policy" if @srtp_outgoing == 0
        ret = LibSRTPDecrypt.srtp_setkey(@srtp_outgoing, ssmk, ssmk.size, sss, sss.size)
        raise "Outgoing SRTP key could not be set (ret == #{ret})" if ret != 0

        @srtp_incoming = LibSRTPDecrypt.srtp_create(LibSRTPDecrypt::SRTP_ENCR_AES_CM, LibSRTPDecrypt::SRTP_AUTH_HMAC_SHA1, taglen, LibSRTPDecrypt::SRTP_PRF_AES_CM, 0)
        raise "Could not create incoming SRTP policy" if @srtp_incoming == 0
        ret = LibSRTPDecrypt.srtp_setkey(@srtp_incoming, scmk, scmk.size, scs, scs.size)
        raise "Incoming SRTP key could not be set (ret == #{ret})" if ret != 0

        # Tell the call handler that the call has begun
        call.handler.queue_event(:start_call)
      end
    end
  end
end
