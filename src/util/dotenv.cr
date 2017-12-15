module Util
  extend self

  class FileMissing < Exception
  end

  class Dotenv
    @@verbose = true

    def self.verbose=(value : Bool) : Bool
      @@verbose = value
    end

    def self.load(path = ".env") : Hash(String, String)
      load File.open(File.expand_path(path))
    rescue ex
      log "DOTENV - Could not open file: #{path}"
      {} of String => String
    end

    def self.load(io : IO) : Hash(String, String)
      hash = {} of String => String
      io.each_line do |line|
        handle_line line, hash
      end
      load hash
      hash
    end

    def self.load(hash : Hash(String, String))
      hash.each do |key, value|
        ENV[key] = value
      end
      ENV
    end

    def self.load!(path = ".env") : Hash(String, String)
      load File.open(File.expand_path(path))
    rescue ex
      raise FileMissing.new("Missing file!")
    end

    def self.load!(io : IO) : Hash(String, String)
      load(io)
    end

    def self.load!(hash : Hash(String, String))
      load(hash)
    end

    private def self.handle_line(line, hash)
      if line !~ /\A\s*(?:#.*)?\z/m
        name, value = line.split("=", 2)
        hash[name.strip] = value.strip
      end
    rescue ex
      log "DOTENV - Malformed line #{line}"
    end

    private def self.log(message : String)
      puts message if @@verbose
    end
  end
end
