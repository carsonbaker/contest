# @[Link(ldflags: "-lsrtp2 -L/usr/local/opt/srtp/lib")]
# 
# lib LibSRTP
# 
#   alias Srtp_t                      = Void*
# 
#   alias Srtp_cipher_type_id_t       = UInt32
#   alias Srtp_auth_type_id_t         = UInt32
#   
#   alias Srtp_ekt_policy_t           = Void*
#   alias Srtp_ekt_stream_t           = Void*
#   
#   enum Srtp_err_status_t
#     SRTP_ERR_STATUS_OK            = 0,   # nothing to report                      
#     SRTP_ERR_STATUS_FAIL          = 1,   # unspecified failure                    
#     SRTP_ERR_STATUS_BAD_PARAM     = 2,   # unsupported parameter                  
#     SRTP_ERR_STATUS_ALLOC_FAIL    = 3,   # couldn't allocate memory               
#     SRTP_ERR_STATUS_DEALLOC_FAIL  = 4,   # couldn't deallocate properly           
#     SRTP_ERR_STATUS_INIT_FAIL     = 5,   # couldn't initialize                    
#     SRTP_ERR_STATUS_TERMINUS      = 6,   # can't process as much data as requested
#     SRTP_ERR_STATUS_AUTH_FAIL     = 7,   # authentication failure                 
#     SRTP_ERR_STATUS_CIPHER_FAIL   = 8,   # cipher failure                         
#     SRTP_ERR_STATUS_REPLAY_FAIL   = 9,   # replay check failed (bad index)        
#     SRTP_ERR_STATUS_REPLAY_OLD    = 10,  # replay check failed (index too old)    
#     SRTP_ERR_STATUS_ALGO_FAIL     = 11,  # algorithm failed test routine          
#     SRTP_ERR_STATUS_NO_SUCH_OP    = 12,  # unsupported operation                  
#     SRTP_ERR_STATUS_NO_CTX        = 13,  # no appropriate context found           
#     SRTP_ERR_STATUS_CANT_CHECK    = 14,  # unable to perform desired validation   
#     SRTP_ERR_STATUS_KEY_EXPIRED   = 15,  # can't use key any more                 
#     SRTP_ERR_STATUS_SOCKET_ERR    = 16,  # error in use of socket                 
#     SRTP_ERR_STATUS_SIGNAL_ERR    = 17,  # error in use POSIX signals             
#     SRTP_ERR_STATUS_NONCE_BAD     = 18,  # nonce check failed                     
#     SRTP_ERR_STATUS_READ_FAIL     = 19,  # couldn't read data                     
#     SRTP_ERR_STATUS_WRITE_FAIL    = 20,  # couldn't write data                    
#     SRTP_ERR_STATUS_PARSE_ERR     = 21,  # error parsing data                     
#     SRTP_ERR_STATUS_ENCODE_ERR    = 22,  # error encoding data                    
#     SRTP_ERR_STATUS_SEMAPHORE_ERR = 23, # error while using semaphores           
#     SRTP_ERR_STATUS_PFKEY_ERR     = 24   # error while using pfkey 
#   end               
# 
#   enum Srtp_ssrc_type_t
#     SSRC_UNDEFINED                  = 0,
#     SSRC_SPECIFIC                   = 1,
#     SSRC_ANY_INBOUND                = 2,
#     SSRC_ANY_OUTBOUND               = 3
#   end
#   
#   enum Srtp_sec_serv_t
#     SEC_SERV_NONE                   = 0,
#     SEC_SERV_CONF                   = 1,
#     SEC_SERV_AUTH                   = 2,
#     SEC_SERV_CONF_AND_AUTH          = 3
#   end
# 
#   struct Srtp_ssrc_t
#     type : Srtp_ssrc_type_t
#     value : UInt32
#   end
#   
#   struct Srtp_crypto_policy_t
#     cipher_type : Srtp_cipher_type_id_t
#     cipher_key_len : Int32
#     auth_type : Srtp_auth_type_id_t
#     auth_key_len : Int32
#     auth_tag_len : Int32
#     sec_serv : Srtp_sec_serv_t
#   end
#   
#   struct Srtp_policy_t
#     ssrc : Srtp_ssrc_t
#     rtp : Srtp_crypto_policy_t
#     rtcp : Srtp_crypto_policy_t
#     key : UInt8*
#     ekt : Srtp_ekt_policy_t
#     window_size : UInt64
#     allow_repeat_tx : Int32
#     enc_xtn_hdr : Int32*
#     enc_xtn_hdr_count : Int32
#     nxt : Srtp_policy_t*
#   end
#   
#   fun srtp_init
#   fun srtp_crypto_policy_set_rtp_default(p : Srtp_crypto_policy_t*)
#   fun srtp_crypto_policy_set_rtcp_default(p : Srtp_crypto_policy_t*)
#   fun srtp_create(session : Srtp_t*, policy : Srtp_policy_t*) : Srtp_err_status_t
#   fun srtp_protect(ctx: Srtp_t, rtp_hdr : Void*, len_ptr : Int32*) : Srtp_err_status_t
#   fun srtp_protect_rtcp(ctx: Srtp_t, rtcp_hdr : Void*, pkt_octet_len : Int32*) : Srtp_err_status_t
#   fun srtp_unprotect(ctx: Srtp_t, srtp_hdr : Void*, len_ptr : Int32*) : Srtp_err_status_t
#   
# end