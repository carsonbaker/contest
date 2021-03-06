require "./dotenv"

class Conf
  # Load from .env
  Util::Dotenv.load

  RTP_PACKET_AUDIO_WALL_TIME = 20 # milliseconds

  SERVER_IP_ADDRESS     = ENV["SERVER_IP_ADDRESS"]? || "127.0.0.1"
  SERVER_LISTEN_ADDRESS = ENV["SERVER_LISTEN_ADDRESS"]? || "0.0.0.0"

  RTP_PORT_RANGE = 49151..65535

  DEFAULT_SIP_PORT = (ENV["DEFAULT_SIP_PORT"]? || 5060).to_i
  API_SERVER_PORT  = (ENV["API_SERVER_PORT"]? || 4000).to_i
  WEB_RTC_PORT     = (ENV["WEB_RTC_PORT"]? || 3892).to_i

  WATSON_TTS_USERNAME = ENV["WATSON_TTS_USERNAME"]?
  WATSON_TTS_PASSWORD = ENV["WATSON_TTS_PASSWORD"]?
end
