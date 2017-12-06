@[Link(ldflags: "-lsamplerate")]

lib LibSampleRate

  enum ConverterType
    SRC_SINC_BEST_QUALITY     = 0
    SRC_SINC_MEDIUM_QUALITY   = 1
    SRC_SINC_FASTEST          = 2
    SRC_ZERO_ORDER_HOLD       = 3
    SRC_LINEAR                = 4
  end

  # data_in       : A pointer to the input data samples.
  # input_frames  : The number of frames of data pointed to by data_in.
  # data_out      : A pointer to the output data samples.
  # output_frames : Maximum number of frames pointer to by data_out.
  # src_ratio     : Equal to output_sample_rate / input_sample_rate.
  
  struct Src_data
    data_in : Float32*
    data_out : Float32*
    
    input_frames : Int64
    output_frames : Int64
    
    input_frames_used : Int64
    output_frames_gen : Int64
    
    end_of_input : Int32
    src_ratio : Float64
    
  end
  
  fun src_strerror(error : Int32) : LibC::Char*
  fun src_simple(data : Src_data*, converter_type : Int32, channels : Int32) : Int32

end

