# @[Link(ldflags: "-lopus")]
@[Link("opus")]

lib LibOpus

  alias OpusEncoderPtr = Void*
  alias OpusDecoderPtr = Void*

  OPUS_OK                               = 0
  OPUS_BAD_ARG                          = -1
  OPUS_BUFFER_TOO_SMALL                 = -2
  OPUS_INTERNAL_ERROR                   = -3
  OPUS_INVALID_PACKET                   = -4
  OPUS_UNIMPLEMENTED                    = -5
  OPUS_INVALID_STATE                    = -6
  OPUS_ALLOC_FAIL                       = -7
  OPUS_APPLICATION_VOIP                 = 2048
  OPUS_APPLICATION_AUDIO                = 2049
  OPUS_APPLICATION_RESTRICTED_LOWDELAY  = 2051
  OPUS_SIGNAL_VOICE                     = 3001
  OPUS_SIGNAL_MUSIC                     = 3002
  OPUS_SET_BITRATE_REQUEST              = 4002
  OPUS_SET_VBR_REQUEST                  = 4006
  OPUS_RESET_STATE                      = 4028
  
  fun opus_encoder_get_size(channels : Int32) : Int32
  fun opus_encoder_create(fs : Int32, channels : Int32, application : Int32, error : Int32*) : OpusEncoderPtr
  fun opus_encoder_init(st : OpusEncoderPtr, fs : Int32, channels : Int32, application : Int32) : Int32
  fun opus_encode(st : OpusEncoderPtr, pcm : Int16*, frame_size : Int32, data : UInt8*, max_data_bytes : Int32) : Int32
  fun opus_encode_float(st : OpusEncoderPtr, pcm : Float32*, frame_size : Int32, data : UInt8*, max_data_bytes : Int32)
  fun opus_encoder_destroy(st : OpusEncoderPtr)
  fun opus_encoder_ctl(st : OpusEncoderPtr, request : Int32, ...)

  fun opus_decoder_get_size(channels : Int32) : Int32
  fun opus_decoder_create(fs : Int32, channels : Int32, error : Int32*) : OpusDecoderPtr
  fun opus_decoder_init(st : OpusDecoderPtr, fs : Int32, channels : Int32) : Int32
  fun opus_decode(st : OpusDecoderPtr, data : UInt8*, len : Int32, pcm : Int16*, frame_size : Int32, decode_fec : Int32) : Int32
  fun opus_decode_float(st : OpusDecoderPtr, data : UInt8*, len : Int32, pcm : Float32*, frame_size : Int32, decode_fec : Int32) : Int32
  fun opus_decoder_ctl(st : OpusDecoderPtr, request : Int32, ...)
  fun opus_decoder_destroy(st : OpusDecoderPtr)
  
end
