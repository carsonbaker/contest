require "string_scanner"

module SIP
    
  class Header
    getter command
    getter vias

    @command : String

    alias StrAddressWithOptionalPort = {host: String, port: Int32 | Nil}
    NEWLINE_DELIMITER = /\n|\r\n/

    def self.parse_ip_w_optional_port(str) : StrAddressWithOptionalPort
      ip_or_hostname_w_port_splits = str.split(":")
      if ip_or_hostname_w_port_splits.size == 1
        return {
          host: ip_or_hostname_w_port_splits[0],
          port: nil,
        }
      elsif ip_or_hostname_w_port_splits.size == 2
        return {
          host: ip_or_hostname_w_port_splits[0],
          port: ip_or_hostname_w_port_splits[1].to_i,
        }
      else
        raise "Could not parse IP string"
      end
    end

    def self.parse_contact_header(contact_header_str : String) : StrAddressWithOptionalPort
      sip_hdr_scanner = StringScanner.new(contact_header_str)

      sip_comp_regex = /\<sip:(?<sip_tag>(.+?))\>/
      # sip_tag_parts = /((?<user>.+?)@)?(?<host>.+?):(?<port>\d+)?/

      if sip_hdr_scanner.scan_until(sip_comp_regex)
        str = sip_hdr_scanner["sip_tag"]?.as(String)

        sip_tag_division = str.split("@")
        host_section = str
        if sip_tag_division.size == 2
          # there is a user section
          host_section = sip_tag_division[1]
        end

        ip_or_hostname_w_port = host_section.split(";").first
        return self.parse_ip_w_optional_port(ip_or_hostname_w_port)
      end

      raise "Could not find <sip> tag in Contact: header"
    end

    def initialize(buffer : String)
      lines = buffer.split(NEWLINE_DELIMITER) # break on newlines
      raise "Could not parse SIP header" if lines.size == 0
      @command = lines.shift
      @header_kvs = {} of String => String
      @vias = [] of String
      lines.each do |line|
        foo = line.split(": ")
        if foo[0] == "Via"
          @vias.push foo[1]
        else
          @header_kvs[foo[0]] = foo[1]
        end
      end
    end

    def content_length
      @header_kvs["Content-Length"].to_i
    end

    def command
      return @command.split(/\s/).first
    end

    def request_uri
      return @command.split(/\s/)[1]
    end

    def contact_info : StrAddressWithOptionalPort
      return self.class.parse_contact_header(@header_kvs["Contact"])
    end

    def from
      @header_kvs["From"]
    end

    def to
      @header_kvs["To"]
    end

    def cseq
      @header_kvs["CSeq"]
    end

    def top_via_info : StrAddressWithOptionalPort
      str = @vias.first
      host_ip_sec = str.split(";")[0]
      host_n_port = host_ip_sec.split("SIP/2.0/UDP ")[1]
      return self.class.parse_ip_w_optional_port(host_n_port)
    end

    def call_id
      @header_kvs["Call-ID"]
    end
  end

end