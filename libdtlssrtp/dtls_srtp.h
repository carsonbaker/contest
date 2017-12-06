/* Copyright (C) Richfit Information Technology Co.Ltd.
   Contributed by Xie Tianming <persmule@gmail.com>, 2015.

   The DTLS-SRTP library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The DTLS-SRTP library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the DTLS-SRTP library; if not, see
   <http://www.gnu.org/licenses/>.  */

#ifndef DTLS_SRTP_H
#define DTLS_SRTP_H

#include <openssl/bio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

// for data_sink
#include "data_sink.h"


#include <assert.h>
#include <stdbool.h>
#include <stdint.h>

// for mutex
#include <pthread.h>

#ifdef __cplusplus
extern "C" {
#endif

enum dtls_verify_mode {
  DTLS_VERIFY_NONE = 0,               /*!< Don't verify anything */
  DTLS_VERIFY_FINGERPRINT = (1 << 0), /*!< Verify the fingerprint */
  DTLS_VERIFY_CERTIFICATE = (1 << 1), /*!< Verify the certificate */
};

enum dtls_con_state {
  DTLS_CONSTATE_ACT, //Endpoint is willing to inititate connections.
  DTLS_CONSTATE_PASS, //Endpoint is willing to accept connections.
  DTLS_CONSTATE_ACTPASS, //Endpoint is willing to both accept and initiate connections
  DTLS_CONSTATE_HOLDCONN, //Endpoint does not want the connection to be established right now
};

enum dtls_con_type {
  DTLS_CONTYPE_NEW=false, //Endpoint wants to use a new connection
  DTLS_CONTYPE_EXISTING=true, //Endpoint wishes to use existing connection
};

enum srtp_profile {
  SRTP_PROFILE_RESERVED=0,
  SRTP_PROFILE_AES128_CM_SHA1_80=1,
  SRTP_PROFILE_AES128_CM_SHA1_32=2,
};

  /*
   * A function prototype used to intercept the regular procedure 
   * of OpenSSL to verify a certificate.
   */
#define SSL_VERIFY_CB(x) int (x)(int preverify_ok, X509_STORE_CTX *ctx)
typedef SSL_VERIFY_CB(ssl_verify_cb);

  // A trivial_verify_callback that always returns OK.
extern SSL_VERIFY_CB(dtls_trivial_verify_callback);

  /*
   * A structure containing all essential info to create a valid SSL_CTX
   * object, as well as a constant value representing srtp cipher 
   * suites supported by OpenSSL to negotiate. NOTE: it has no special 
   * memory management ability, so its member must be freed (if needed) 
   * accordingly.
   */
typedef struct tlscfg {
  X509* cert;
  EVP_PKEY* pkey;
  enum srtp_profile profile;
  const char* cipherlist;
  const char* cafile;
  const char* capath;
}tlscfg;

  /*
   * A function to create an SSL_CTX object from a 'tlscfg', and mode
   * to verify peer's certificate, as well as proper 'ssl_verify_cb'. 
   * NOTE: if verify_mode is DTLS_VERIFY_CERTIFICATE, the value of 
   * 'cb' is ignored, otherwise the 'ssl_verify_cb' passed in, or
   * the default dtls_trivial_verify_callback (if 'cb' is NULL)
   * is applied.
   */
SSL_CTX* dtls_ctx_init(
		       int verify_mode,
		       ssl_verify_cb* cb,
		       const tlscfg* cfg
		       );
  /*
   * The basic 'class' representing a dtls session to perform dtls_srtp 
   * negotiation. Most functions below are 'member functions' for 
   * this type.
   */
typedef struct dtls_sess {
  SSL* ssl;
  const dsink* sink;
  enum dtls_con_state state;
  enum dtls_con_type type;
  pthread_mutex_t lock;
}dtls_sess;

  /*
   * Reset a dtls_sess which has completed negotiation to its
   * initial state. NOTE: this function does not affect dtls_sess
   * which has NOT completed negotiation.
   */
void dtls_sess_setup(dtls_sess* sess);

  /*
   * Create a new dtls_sess from an existing SSL_CTX object, using
   * data sink 'sink' to perform essential communication, then set
   * its initial state according to 'con_state', which usually is
   * DTLS_CONSTATE_ACT, if this endpoint is going to start a handshake;
   * DTLS_CONSTATE_PASS, if this endpoint is going to receive handshake
   * from a peer passively, or DTLS_CONSTATE_ACTPASS, making this
   * endpoint able to start a handshake and transform to
   * DTLS_CONSTATE_ACT, and retain the ability to receive handshake
   * and transform to DTLS_CONSTATE_PASS.
   */
dtls_sess* dtls_sess_new(
			 SSL_CTX* sslcfg,
			 const dsink* sink,
			 int con_state
			 );

  // End the life of a dtls_sess object.
void dtls_sess_free(dtls_sess* sess);
  
  /*
   * Send potential pending packets generated by the underlying SSL
   * object to 'dest', via 'carrier' (see data_sink.h). This function
   * are usually invoked by other communication-related functions.
   */
ptrdiff_t dtls_sess_send_pending(
				 dtls_sess* sess,
				 void* carrier,
				 const void* dest,
				 int destlen
				 );

  /*
   * Put a received dtls packet into the dtls_sess, and send any 
   * potential pending packets.
   */
ptrdiff_t dtls_sess_put_packet(
			       dtls_sess* sess,
			       void* carrier,
			       const void* buf,
			       size_t len,
			       const void* dest,
			       int destlen
			       );

  /*
   * Start handshaking and send generated packet. NOTE: this function
   * has effects only on a dtls_srtp object on DTLS_CONSTATE_ACT and
   * DTLS_CONSTATE_ACTPASS state, and change the state to
   * DTLS_CONSTATE_ACT after returning.
   */
ptrdiff_t dtls_do_handshake(
			    dtls_sess* sess,
			    void* carrier,
			    const void* dest,
			    int destlen
			    );

  /*
   * Supposed to be used by carriers with timer. The timer within
   * carrier will call this function to handle timeout and send
   * generated packets.
   */
ptrdiff_t dtls_sess_handle_timeout(
				   dtls_sess* sess,
				   void* carrier,
				   const void* dest,
				   int destlen
				   );

  /*
   * Simple wrapper function of DTLSv1_get_timeout, to get the
   * remaining time before timeout from underlying SSL object.
   * Supposed to be used by carriers with timer.
   */
static inline int dtls_sess_get_timeout(
					const dtls_sess* sess,
					struct timeval* tv
					)
{
  return DTLSv1_get_timeout(sess->ssl, tv);
}

  //Shutdown completed DTLS session and make it ready to start a new one
static inline void dtls_sess_reset(dtls_sess* sess)
{
  if(SSL_is_init_finished(sess->ssl)){
    SSL_shutdown(sess->ssl);
    sess->type = DTLS_CONTYPE_NEW;
  }
}

  //Setter and getter for data sink virtual table.
static inline const dsink* dtls_sess_get_sink(const dtls_sess* sess)
{return sess->sink;}

static inline void dtls_sess_set_sink(dtls_sess* sess, const dsink* sink)
{sess->sink = sink;}

  /*
   * Perform renegotiation, usually on dtls_sess objects with
   * communication error.
   */
static inline void dtls_sess_renegotiate(
					 dtls_sess* sess,
					 void* carrier,
					 const void* dest,
					 int destlen
					 )
{
  SSL_renegotiate(sess->ssl);
  SSL_do_handshake(sess->ssl);
  dtls_sess_send_pending(sess, carrier, dest, destlen);
}

  /*
   * Get a pointer to the certificate sent from peer, which can be used
   * to perform some authentication.
   */
static inline X509* dtls_sess_get_peer_certificate(dtls_sess* sess)
{return SSL_get_peer_certificate(sess->ssl);}

  /*
   * Detect whether a packet is a dtls one. It is essential for a rtp
   * receiver to demultiplex dtls packets from rtp packets and put
   * them into a dtls_sess object.
   */
static inline bool packet_is_dtls(const void* buf, size_t dummy_len)
{(void)dummy_len;return (*(const char*)buf >= 20) && (*(const char*)buf <= 64);}

  // simple getter and setter for member dtls_con_state.
static inline void dtls_sess_set_state(dtls_sess* sess, enum dtls_con_state state)
{sess->state = state;}
static inline enum dtls_con_state dtls_sess_get_state(const dtls_sess* sess)
{return sess->state;}

  // simple getter for underlying BIOs.
static inline BIO* dtls_sess_get_rbio(dtls_sess* sess)
{return SSL_get_rbio(sess->ssl);}
static inline BIO* dtls_sess_get_wbio(dtls_sess* sess)
{return SSL_get_wbio(sess->ssl);}

#define MASTER_KEY_LEN 16
#define MASTER_SALT_LEN 14
  
  /*
   * Structure representing raw srtp key materials as a binary blob
   * extracted directly from an SSL object.
   */
typedef struct srtp_key_material{
  uint8_t material[(MASTER_KEY_LEN + MASTER_SALT_LEN) * 2];
  enum dtls_con_state ispassive;
}srtp_key_material;

  /*
   * Pointers to specific parts (with fixed lengths) of key material, judged by direction
   * info within srtp_key_material structures.
   */
typedef struct srtp_key_ptrs{
  const uint8_t* localkey;
  const uint8_t* remotekey;
  const uint8_t* localsalt;
  const uint8_t* remotesalt;
}srtp_key_ptrs;

  /*
   * Extract raw srtp key material from a dtls_sess object. Use
   * key_material_free to free it.
   */
srtp_key_material* srtp_get_key_material(dtls_sess* sess);

void key_material_free(srtp_key_material* km);

  /*
   * Assign Pointers to specific parts according to direction info
   * within srtp_key_material structures.
   */
static inline void srtp_key_material_extract
(const srtp_key_material* km, srtp_key_ptrs* ptrs)
{
  if(km->ispassive == DTLS_CONSTATE_ACT){
    ptrs->localkey = (km->material);
    ptrs->remotekey = ptrs->localkey + MASTER_KEY_LEN;
    ptrs->localsalt = ptrs->remotekey + MASTER_KEY_LEN;
    ptrs->remotesalt = ptrs->localsalt + MASTER_SALT_LEN;
  }else{
    ptrs->remotekey = (km->material);
    ptrs->localkey = ptrs->remotekey + MASTER_KEY_LEN;
    ptrs->remotesalt = ptrs->localkey + MASTER_KEY_LEN;
    ptrs->localsalt = ptrs->remotesalt + MASTER_SALT_LEN;
  }
}





  //some trivial functions to deal with strings.
static inline bool str_isempty(const char* str)
{return ((str == NULL) || (str[0] == '\0'));}

static inline const char* str_nullforempty(const char* str)
{return (str_isempty(str)?NULL:str);}

  //init and uninit openssl library.
static inline int dtls_init_openssl(void)
{
  OpenSSL_add_ssl_algorithms();
  SSL_load_error_strings();
  return SSL_library_init();
}


static inline void dtls_uninit_openssl(void)
{
  ERR_free_strings();
  EVP_cleanup();
}



#ifdef __cplusplus
}
#endif

#endif
