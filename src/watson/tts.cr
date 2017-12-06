require "http/client"
require "json"

require "../conf"

module Watson
  class TTS
    
    def initialize
      @host = "https://stream.watsonplatform.net"
      @api = "/text-to-speech/api"
      @version = "v1"
    end

    def synthesize(text, format = "audio/l16;rate=48000") : Bytes
      
      # audio/ogg;codecs=opus (the default)
      # audio/wav
      # audio/flac
      # audio/webm
      # audio/webm;codecs=opus
      # audio/webm;codecs=vorbis
      # audio/l16;rate=rate
      # audio/mulaw;rate=rate
      # audio/basic
      
      # https://www.ibm.com/watson/developercloud/text-to-speech/api/v1/#get_voices
      
      audio_format    = "audio/l16;rate=48000"
      
      headers   = HTTP::Headers{
        "User-agent"   => "IBM-Watson-Crystal-Lib",
        "Content-Type" => "application/json",
        "Accept"       => audio_format
      }
      voice           = "en-US_AllisonVoice" # "en-US_LisaVoice"
      body            = { :text => text }
      body_json       = body.to_json
      
      uri = URI.parse(@host)
      path = method_url("synthesize?voice=#{voice}")
      
      client = HTTP::Client.new(uri)
      client.basic_auth(Conf::WATSON_TTS_USERNAME, Conf::WATSON_TTS_PASSWORD)
      client.connect_timeout = 5.seconds
      
      response = client.post(path, headers, body_json)
      
      if response.success?
        return response.body.to_slice
      else
        raise "Watson noped."
      end
  
    end
    
    private def method_url(method)
      String.build do |str|
        str << @api << "/" << @version << "/" << method
      end
    end
    
  end
  
end
