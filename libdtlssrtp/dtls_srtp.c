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

#include "dtls_srtp.h"

SSL_VERIFY_CB(dtls_trivial_verify_callback)
{
  //TODO: add actuall verify routines here, if needed.
  (void)preverify_ok;
  (void)ctx;
  return 1;
}

SSL_CTX* dtls_ctx_init(
		       int verify_mode,
		       ssl_verify_cb* cb,
		       const tlscfg* cfg
		       )
{

  SSL_CTX* ctx = NULL;
#ifndef HAVE_OPENSSL_ECDH_AUTO
  EC_KEY *ecdh = NULL;
#endif

  
  ctx = SSL_CTX_new(DTLSv1_method());
  
  SSL_CTX_set_read_ahead(ctx, true);
#ifdef HAVE_OPENSSL_ECDH_AUTO
  SSL_CTX_set_ecdh_auto(ctx, true);
  
#else
  if (NULL != (ecdh = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1))) {
    SSL_CTX_set_tmp_ecdh(ctx, ecdh);
    EC_KEY_free(ecdh);
  }

#endif
  // TODO -- I had the following statement commented out.
  // not sure what the right thing to do is.
  SSL_CTX_set_verify(ctx,
		     (verify_mode & DTLS_VERIFY_FINGERPRINT)
		     || (verify_mode & DTLS_VERIFY_CERTIFICATE) ?
		     SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT
		     : SSL_VERIFY_NONE,
		     !(verify_mode & DTLS_VERIFY_CERTIFICATE) ?
		     (cb ? cb:dtls_trivial_verify_callback) : NULL
		     );
  
  // SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, NULL);

  switch(cfg->profile) {
  case SRTP_PROFILE_AES128_CM_SHA1_80:
    SSL_CTX_set_tlsext_use_srtp(ctx, "SRTP_AES128_CM_SHA1_80");
    break;
  case SRTP_PROFILE_AES128_CM_SHA1_32:
    SSL_CTX_set_tlsext_use_srtp(ctx, "SRTP_AES128_CM_SHA1_32");
    break;
  default:
    SSL_CTX_free(ctx);
    return NULL;
  }
  
  if(cfg->cert != NULL) {
    if (!SSL_CTX_use_certificate(ctx, cfg->cert)) {
      SSL_CTX_free(ctx);
      return NULL;
    }
    
    if (!SSL_CTX_use_PrivateKey(ctx, cfg->pkey) ||
	!SSL_CTX_check_private_key(ctx)) {
      SSL_CTX_free(ctx);
      return NULL;
    }
  }
  
  if (!str_isempty(cfg->cipherlist)) {
    if (!SSL_CTX_set_cipher_list(ctx, cfg->cipherlist)) {
      SSL_CTX_free(ctx);
      return NULL;
    }
  }
  
  if (!str_isempty(cfg->cafile) || !str_isempty(cfg->capath)) {
    if (!SSL_CTX_load_verify_locations(ctx, str_nullforempty(cfg->cafile), str_nullforempty(cfg->capath))) {
      SSL_CTX_free(ctx);
      return NULL;
    }
  }
  
  return ctx;
}

dtls_sess* dtls_sess_new(
			 SSL_CTX* sslcfg,
			 const dsink* sink,
			 int con_state
			 )
{
  dtls_sess* sess = (dtls_sess*)calloc(1, sizeof(dtls_sess));
  BIO* rbio = NULL;
  BIO* wbio = NULL;

  sess->state = con_state;
  
  if (NULL == (sess->ssl = SSL_new(sslcfg))) {
    goto error;
  }

  if (NULL == (rbio = BIO_new(BIO_s_mem()))) {
    goto error;
  }

  BIO_set_mem_eof_return(rbio, -1);

  if (NULL == (wbio = BIO_new(BIO_s_mem()))) {
    BIO_free(rbio);
    rbio = NULL;
    goto error;
  }

  BIO_set_mem_eof_return(wbio, -1);

  SSL_set_bio(sess->ssl, rbio, wbio);
  
  /*SSL_set_bio does not change ref count of BIOs to set!!!
    BIO_free(rbio);
    BIO_free(wbio);*/

  if (sess->state == DTLS_CONSTATE_PASS) {
    SSL_set_accept_state(sess->ssl);
  } else {
    SSL_set_connect_state(sess->ssl);
  }
  sess->type = DTLS_CONTYPE_NEW;
  
  pthread_mutex_init(&sess->lock, NULL);
  dtls_sess_set_sink(sess, sink);
  return sess;
  
 error:
  if(sess->ssl != NULL) {
    SSL_free(sess->ssl);
    sess->ssl = NULL;
  }
  free(sess);
  return NULL;
}

void dtls_sess_free(dtls_sess* sess)
{
  if(sess->ssl != NULL) {
    SSL_free(sess->ssl);
    sess->ssl = NULL;
  }
  pthread_mutex_destroy(&sess->lock);
  free(sess);
}

ptrdiff_t dtls_sess_send_pending(
				 dtls_sess* sess,
				 void* carrier,
				 const void* dest,
				 int destlen
				 )
{
  if(sess->ssl == NULL){
    return -2;
  }
  BIO* wbio = dtls_sess_get_wbio(sess);
  size_t pending = BIO_ctrl_pending(wbio);
  size_t out = 0;
  ptrdiff_t ret = 0;
  if(pending > 0) {
    char outgoing[pending];
    out = BIO_read(wbio, outgoing, pending);
    if(sess->sink->sched != NULL){
      struct timeval tv = {0, 0};
      sess->sink->sched(carrier,
			dtls_sess_get_timeout(sess, &tv)?&tv:NULL);
    }
    // ret = sendto(carrier, outgoing, out, MSG_DONTWAIT, dest, destlen);
    ret = sess->sink->sendto(carrier, outgoing, out, 0, dest, destlen);
  }
  return ret;
}

ptrdiff_t dtls_sess_put_packet(
			       dtls_sess* sess,
			       void* carrier,
			       const void* buf,
			       size_t len,
			       const void* dest,
			       int destlen
			       )
{
  ptrdiff_t ret = 0;
  char dummy[len];
  
  if(sess->ssl == NULL){
    return -1;
  }

  pthread_mutex_lock(&sess->lock);
  pthread_mutex_unlock(&sess->lock);


  BIO* rbio = dtls_sess_get_rbio(sess);

  if(sess->state == DTLS_CONSTATE_ACTPASS){
    sess->state = DTLS_CONSTATE_PASS;
    SSL_set_accept_state(sess->ssl);
  }

  dtls_sess_send_pending(sess, carrier, dest, destlen);

  BIO_write(rbio, buf, len);
  ret = SSL_read(sess->ssl, dummy, len);

  if((ret < 0) && SSL_get_error(sess->ssl, ret) == SSL_ERROR_SSL){
    return ret;
  }

  dtls_sess_send_pending(sess, carrier, dest, destlen);

  if(SSL_is_init_finished(sess->ssl)){
    sess->type = DTLS_CONTYPE_EXISTING;
  }

  return ret;
  
}

ptrdiff_t dtls_do_handshake(
			    dtls_sess* sess,
			    void* carrier,
			    const void* dest,
			    int destlen
			    )
{
  /* If we are not acting as a client connecting to the remote side then
   * don't start the handshake as it will accomplish nothing and would conflict
   * with the handshake we receive from the remote side.
   */
  if(sess->ssl == NULL
     || (dtls_sess_get_state(sess) != DTLS_CONSTATE_ACT
	 && dtls_sess_get_state(sess) != DTLS_CONSTATE_ACTPASS)){
    return 0;
  }
  if(dtls_sess_get_state(sess) == DTLS_CONSTATE_ACTPASS){
    dtls_sess_set_state(sess, DTLS_CONSTATE_ACT);
  }
  SSL_do_handshake(sess->ssl);
  pthread_mutex_lock(&sess->lock);
  ptrdiff_t ret = dtls_sess_send_pending(sess, carrier, dest, destlen);
  pthread_mutex_unlock(&sess->lock);
  return ret;
}

ptrdiff_t dtls_sess_handle_timeout(
				   dtls_sess* sess,
				   void* carrier,
				   const void* dest,
				   int destlen
				   )
{
  if(!SSL_is_init_finished(sess->ssl)){
    DTLSv1_handle_timeout(sess->ssl);
  }
  return dtls_sess_send_pending(sess, carrier, dest, destlen);
}




void dtls_sess_setup(dtls_sess* sess)
{
  if(sess->ssl == NULL || !SSL_is_init_finished(sess->ssl)){
    return;
  }

  SSL_clear(sess->ssl);
  if (sess->state == DTLS_CONSTATE_PASS) {
    SSL_set_accept_state(sess->ssl);
  } else {
    SSL_set_connect_state(sess->ssl);
  }
  sess->type = DTLS_CONTYPE_NEW;
}

srtp_key_material* srtp_get_key_material(dtls_sess* sess)
{
  if(!SSL_is_init_finished(sess->ssl)){
    return NULL;
  }
  
  const char * label = "EXTRACTOR-dtls_srtp";

  srtp_key_material* km = calloc(1, sizeof(srtp_key_material));

  if(!SSL_export_keying_material(sess->ssl, km->material, sizeof(km->material), label, strlen(label), NULL, 0, 0)){
    key_material_free(km);
    return NULL;
  }

  km->ispassive = sess->state;
  
  return km;
}

void key_material_free(srtp_key_material* km)
{
  memset(km->material, 0, sizeof(km->material));
  free(km);
}
