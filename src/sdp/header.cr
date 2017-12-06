require "string_scanner"

module SDP
  class Header
    getter version : String
    getter media : String
    getter session_attributes : Array(String)
    getter connection_info : String
    getter originator : String
    getter ice_userfrag : String?
    getter ice_password : String?

    RTCP_ATTRIBUTE_REGEX = /^rtcp:(?<port>\d+) (IN) (IP4|IP6) (?<host>.+?)$/
    RTP_MAP_REGEX = /^rtpmap:(?<id>\d+) (?<codec>.+?)$/

    def initialize(buffer : String)
      
      @candidate_attribute_lines = [] of String
      @session_attributes = [] of String
      @originator = ""
      @media = ""
      @version = ""
      @connection_info = ""
      @ice_userfrag = ""
      @ice_password = ""

      buffer.each_line do |line|
        next if line.empty?
        key, value = line.split('=', 2)
        if key.size > 1
          raise "SDP key length not single char"
        end
        if key == "v"
          @version = value.as(String)
        end
        case key
        when "v"
          @version = value.as(String)
        when "c"
          @connection_info = value.as(String)
        when "o"
          @originator = value.as(String)
        when "m"
          @media = value.as(String)
        when "a"
          @session_attributes << value.as(String)
        end
      end
      
      # Save the ICE username and password
      @session_attributes.each do |a|
        splits = a.split(/:/)
        if splits.size == 2
          k,v = splits
          @ice_userfrag = v if k == "ice-ufrag"
          @ice_password = v if k == "ice-pwd"
        end
      end
      
      # Find any ICE candidates that are included
      @session_attributes.each do |a|
        if a.split(/:/)[0] == "candidate"
          @candidate_attribute_lines.push(a)
        end
      end

    end

    def connection_ip
      @connection_info.split("IN IP4 ")[1]
    end

    def media_port : Int32
      @media.split(' ')[1].to_i
    end

    def has_rtcp_info?
      !rtcp_info_line.blank?
    end

    def rtcp_info_line : String
      @session_attributes.each do |a|
        s = StringScanner.new(a)
        return a if s.scan(RTCP_ATTRIBUTE_REGEX)
      end
      return ""
    end
    
    def ice_username : String
      @session_attributes.each do |a|
        s = StringScanner.new(a)
        return a if s.scan(RTCP_ATTRIBUTE_REGEX)
      end
      return ""
    end
    
    def rtp_map
      map = {} of String => Int32

      @session_attributes.each do |a|
        s = StringScanner.new(a)
        match = s.scan(RTP_MAP_REGEX)
        if match
          id = s["id"]?.as(String).to_i
          codec = s["codec"]?.as(String)
          map[codec] = id
        end
      end
      return map
      
    end
    
    def ice_candidates
      candidates = [] of Hash(Symbol, String)
      @candidate_attribute_lines.each do |value|
        splits = value.split(" ")
        hash = {
          :candidate_id => splits[0],
          :component_id => splits[1],
          :protocol => splits[2].downcase,
          :priority => splits[3],
          :connection_address => splits[4],
          :port => splits[5],
          :cand_type => splits[7]
        }
        candidates.push(hash)
      end
      return candidates
    end

    def rtcp_connect_addr_and_port : NamedTuple(host: String, port: Int32)
      s = StringScanner.new(rtcp_info_line)
      match = s.scan(RTCP_ATTRIBUTE_REGEX)
      if match
        host = s["host"]?.as(String)
        port = s["port"]?.as(String).to_i
        return {host: host, port: port}
      else
        raise "Could not parse rtcp connect attribute"
      end
    end
  end
  
end
