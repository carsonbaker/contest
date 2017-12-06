# @[Link(ldflags: "`pkg-config wolfssl --libs`")]
@[Link("wolfssl")]

lib LibWolfSSL

  # @[Flags]
  enum TEST_FLAGS
    TEST_SELECT_FAIL
    TEST_TIMEOUT
    TEST_RECV_READY
    TEST_ERROR_READY
  end

  SSL_ERROR_NONE        =  0  
  SSL_FAILURE           =  0 
  SSL_SUCCESS           =  1
  SSL_SHUTDOWN_NOT_DONE =  2

  SSL_ALPN_NOT_FOUND    = -9
  SSL_BAD_CERTTYPE      = -8
  SSL_BAD_STAT          = -7
  SSL_BAD_PATH          = -6
  SSL_BAD_FILETYPE      = -5
  SSL_BAD_FILE          = -4
  SSL_NOT_IMPLEMENTED   = -3
  SSL_UNKNOWN           = -2
  SSL_FATAL_ERROR       = -1

  SSL_FILETYPE_ASN1    = 2
  SSL_FILETYPE_PEM     = 1
  SSL_FILETYPE_DEFAULT = 2
  SSL_FILETYPE_RAW     = 3

  SSL_VERIFY_NONE                 = 0
  SSL_VERIFY_PEER                 = 1
  SSL_VERIFY_FAIL_IF_NO_PEER_CERT = 2
  SSL_VERIFY_CLIENT_ONCE          = 4
  SSL_VERIFY_FAIL_EXCEPT_PSK      = 8

  SSL_SESS_CACHE_OFF                = 30
  SSL_SESS_CACHE_CLIENT             = 31
  SSL_SESS_CACHE_SERVER             = 32
  SSL_SESS_CACHE_BOTH               = 33
  SSL_SESS_CACHE_NO_AUTO_CLEAR      = 34
  SSL_SESS_CACHE_NO_INTERNAL_LOOKUP = 35

  SSL_ERROR_WANT_READ        =  2
  SSL_ERROR_WANT_WRITE       =  3
  SSL_ERROR_WANT_CONNECT     =  7
  SSL_ERROR_WANT_ACCEPT      =  8
  SSL_ERROR_SYSCALL          =  5
  SSL_ERROR_WANT_X509_LOOKUP = 83
  SSL_ERROR_ZERO_RETURN      =  6
  SSL_ERROR_SSL              = 85

  SSL_SENT_SHUTDOWN     = 1
  SSL_RECEIVED_SHUTDOWN = 2
  SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER = 4
  SSL_OP_NO_SSLv2       = 8

  SSL_R_SSL_HANDSHAKE_FAILURE           = 101
  SSL_R_TLSV1_ALERT_UNKNOWN_CA          = 102
  SSL_R_SSLV3_ALERT_CERTIFICATE_UNKNOWN = 103
  SSL_R_SSLV3_ALERT_BAD_CERTIFICATE     = 104

  PEM_BUFSIZE = 1024

  type WOLFSSL         = Void*
  type WOLFSSL_CTX     = Void*
  type WOLFSSL_SESSION = Void*
  type WOLFSSL_METHOD  = Void*
  
  fun wolfSSL_Init : Int32
  fun wolfSSL_Cleanup : Int32
  
  fun wolfSSL_new(ctx : WOLFSSL_CTX) : WOLFSSL
  fun wolfSSL_free(ssl : WOLFSSL)
  fun wolfSSL_shutdown(ssl : WOLFSSL) : Int32
  
  fun wolfSSL_accept(ssl : WOLFSSL) : Int32
  
  fun wolfDTLSv1_2_server_method : WOLFSSL_METHOD
  fun wolfSSL_dtls_got_timeout(ssl : WOLFSSL) : Int32
  
  fun wolfSSL_get_error(ssl : WOLFSSL, code : Int32) : Int32
  fun wolfSSL_ERR_error_string(e : UInt64, buf : LibC::Char*)
  fun wolfSSL_ERR_error_string_n(e : UInt64, buf : LibC::Char*, sz : UInt64)
  fun wolfSSL_ERR_reason_error_string(e : UInt64) : LibC::Char*
  
  fun wolfSSL_get_fd(ssl : WOLFSSL) : Int32
  fun wolfSSL_set_fd(ssl : WOLFSSL, fd : Int32) : Int32
  fun wolfSSL_set_using_nonblock(ssl : WOLFSSL, nonblock : Int32)  
  fun wolfSSL_set_verify(ssl : WOLFSSL, mode : Int32, callback : Void*)
  fun wolfSSL_dtls_get_current_timeout(ssl : WOLFSSL) : Int32
  
  fun wolfSSL_write(ssl : WOLFSSL, buffer : Void*, size : Int32) : Int32
  fun wolfSSL_read(ssl : WOLFSSL, buffer : Void*, size : Int32) : Int32

  fun wolfSSL_dtls_set_peer(ssl : WOLFSSL, addr : Void*, addr_size : UInt32)

  fun wolfSSL_Debugging_ON() : Int32
  
  fun wolfSSL_dtls(ssl : WOLFSSL) : Int32
  
  fun wolfSSL_CTX_new(WOLFSSL_METHOD) : WOLFSSL_CTX
  fun wolfSSL_CTX_free(WOLFSSL_CTX)
  
  fun wolfSSL_CTX_load_verify_locations(WOLFSSL_CTX, LibC::Char*, LibC::Char*) : Int32
  fun wolfSSL_CTX_use_certificate_file(WOLFSSL_CTX, LibC::Char*, Int32) : Int32
  fun wolfSSL_CTX_use_PrivateKey_file(WOLFSSL_CTX, LibC::Char*, Int32) : Int32

end
