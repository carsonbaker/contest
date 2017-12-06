require "openssl/lib_ssl"

lib LibCrypto
  fun x509_digest = X509_digest(cert : LibCrypto::X509, type : LibCrypto::EVP_MD, fingerprint : Char*, size : UInt32*) : Int32
end

lib LibSSL
  fun ssl_get_peer_certificate = SSL_get_peer_certificate(ssl : SSL) : LibCrypto::X509
  fun openssl_add_all_ciphers = OpenSSL_add_all_ciphers
  fun dtls_server_method = DTLS_server_method : SSLMethod
  fun dtls_v1_2_server_method = DTLSv1_2_server_method : SSLMethod
  fun dtlsv1_method = DTLSv1_method : SSLMethod
  fun ssl_ctx_set_tlsext_use_srtp = SSL_CTX_set_tlsext_use_srtp(ctx : SSLContext, profiles : Char*)
end

@[Link(ldflags: "#{__DIR__}/../../libdtlssrtp/libdtlssrtp.a -L/usr/local/opt/openssl/lib")]

lib LibDTLSSRTP
  MASTER_KEY_LEN        = 16
  MASTER_SALT_LEN       = 14
  SRTP_KEY_MATERIAL_LEN = (MASTER_KEY_LEN + MASTER_SALT_LEN) * 2

  enum Dtls_verify_mode
    DTLS_VERIFY_NONE        = 0        # Don't verify anything
    DTLS_VERIFY_FINGERPRINT = (1 << 0) # Verify the fingerprint
    DTLS_VERIFY_CERTIFICATE = (1 << 1) # Verify the certificate
  end

  enum Dtls_con_state
    DTLS_CONSTATE_ACT      # Endpoint is willing to inititate connections.
    DTLS_CONSTATE_PASS     # Endpoint is willing to accept connections.
    DTLS_CONSTATE_ACTPASS  # Endpoint is willing to both accept and initiate connections
    DTLS_CONSTATE_HOLDCONN # Endpoint does not want the connection to be established right now
  end

  enum Dtls_con_type
    DTLS_CONTYPE_NEW      = 0 # Endpoint wants to use a new connection
    DTLS_CONTYPE_EXISTING = 1 # Endpoint wishes to use existing connection
  end

  enum Srtp_profile
    SRTP_PROFILE_RESERVED          = 0
    SRTP_PROFILE_AES128_CM_SHA1_80 = 1
    SRTP_PROFILE_AES128_CM_SHA1_32 = 2
  end

  struct Tlscfg
    cert : Void* # LibCrypto::X509
    pkey : Void* # should be EVP_PKEY*
    profile : Srtp_profile
    cipherlist : LibC::Char*
    cafile : LibC::Char*
    capath : LibC::Char*
  end

  struct Dtls_sess
    ssl : LibSSL::SSL
    sink : Dsink*
    state : Dtls_con_state
    type : Dtls_con_type
    lock : LibC::PthreadMutexT*
  end

  struct Dsink
    name : LibC::Char*
    sendto : Int32, Void*, Int32, Int32, LibC::Sockaddr*, LibC::SocklenT -> LibC::SSizeT
    sched : Void*
  end

  struct Srtp_key_material
    material : UInt8[SRTP_KEY_MATERIAL_LEN]
    ispassive : Dtls_con_state
  end

  fun dtls_sess_setup(sess : Dtls_sess*)
  fun dtls_ctx_init(verify_mode : Int32, cb : Void*, cfg : Tlscfg*) : LibSSL::SSLContext
  fun dtls_sess_new(ssl_ctx : LibSSL::SSLContext, sink : Dsink*, con_state : Int32) : Dtls_sess*
  fun dtls_sess_free(sess : Dtls_sess*)
  fun dtls_sess_send_pending(sess : Dtls_sess*, carrier : Int32, dest : Void*, destlen : Int32) : Int32
  fun dtls_sess_put_packet(sess : Dtls_sess*, carrier : Int32, buf : Void*, len : Int32, dest : Void*, destlen : Int32) : Int32
  fun dtls_do_handshake(sess : Dtls_sess*, carrier : Int32, dest : Void*, destlen : Int32) : Int32
  fun dtls_sess_handle_timeout(sess : Dtls_sess*, carrier : Int32, dest : Void*, destlen : Int32) : Int32
  fun dtls_sess_get_timeout(sess : Dtls_sess*, timeval : LibC::Timeval*)
  fun dtls_sess_reset(sess : Dtls_sess*)
  fun dtls_sess_get_sink(sess : Dtls_sess*)
  fun dtls_sess_set_sink(sess : Dtls_sess*, sink : Dsink*)
  fun dtls_sess_renegotiate(sess : Dtls_sess*, carrier : Int32, dest : Void*, destlen : Int32)

  fun srtp_get_key_material(sess : Dtls_sess*) : Srtp_key_material*
  fun key_material_free(km : Srtp_key_material*)
end
