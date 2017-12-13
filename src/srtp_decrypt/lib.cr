@[Link(ldflags: "`libgcrypt-config --libs`")]
@[Link(ldflags: "#{__DIR__}/../../libsrtp_decrypt/srtp.a")]

lib LibSRTPDecrypt
  
  alias Srtp_session_ptr = Void*
  
  SRTP_UNENCRYPTED       = 0x1  # do not encrypt SRTP packets
  SRTCP_UNENCRYPTED      = 0x2  # do not encrypt SRTCP packets
  SRTP_UNAUTHENTICATED   = 0x4  # authenticate only SRTCP packets
  SRTP_RCC_MODE1         = 0x10 # use Roll-over-Counter Carry mode 1
  SRTP_RCC_MODE2         = 0x20 # use Roll-over-Counter Carry mode 2
  SRTP_RCC_MODE3         = 0x30 # use Roll-over-Counter Carry mode 3 (insecure)
  SRTP_FLAGS_MASK        = 0x37 # mask for valid flags

  # SRTP encryption algorithms (ciphers); same values as MIKEY
  SRTP_ENCR_NULL         = 0  # no encryption
  SRTP_ENCR_AES_CM       = 1  # AES counter mode
  SRTP_ENCR_AES_F8       = 2  # AES F8 mode (not implemented)

  # SRTP authenticaton algorithms; same values as MIKEY
  SRTP_AUTH_NULL         = 0  # no authentication code
  SRTP_AUTH_HMAC_SHA1    = 1  # HMAC-SHA1

  # SRTP pseudo random function; same values as MIKEY
  SRTP_PRF_AES_CM = 0 # AES counter mode

  fun srtp_create(encr : Int32, auth : Int32, tag_len : UInt32, prf : Int32, flags : UInt32) : Srtp_session_ptr
  fun srtp_destroy(s : Srtp_session_ptr)
  fun srtp_setkey(s : Srtp_session_ptr, key : Void*, keylen : LibC::SizeT, salt : Void*, saltlen : LibC::SizeT) : Int32
  fun srtp_setkeystring(s : Srtp_session_ptr) : Int32
  fun srtp_setrcc_rate(s : Srtp_session_ptr, rate : UInt16)
  
  fun srtp_send(s : Srtp_session_ptr, buf : UInt8*, lenp : LibC::SizeT*, maxsize : LibC::SizeT) : Int32
  fun srtp_recv(s : Srtp_session_ptr, buf : UInt8*, lenp : LibC::SizeT*) : Int32
  
  fun srtcp_send(s : Srtp_session_ptr, buf : UInt8*, lenp : LibC::SizeT*, maxsize : LibC::SizeT) : Int32
  fun srtcp_recv(s : Srtp_session_ptr, buf : UInt8*, lenp : LibC::SizeT*) : Int32
  
  fun srtp_init_seq(s : Srtp_session_ptr, buf : UInt8*)
  
end
