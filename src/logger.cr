require "logger"

# Convenience logger class

class L
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG
  # @@logger.formatter = self.our_formatter

  RESET_SEQ    = "\033[0m"
  STAR_SEQ     = "\033[1;40m"
  DARK_RED_SEQ = "\033[1;41m"
  RED_SEQ      = "\033[1;101m"
  YELLOW_SEQ   = "\033[1;93m"
  MAGENTA_SEQ  = "\033[1;34m"
  BOLD_SEQ     = "\033[1m"

  def self.our_formatter
    # API change in Crystal 0.23 makes severity an enum and breaks this method
    # Logger::Formatter.new do |severity, datetime, progname, message, io|
    #   io << severity.rjust(5) << " -- " << progname << ": " << message
    # end
  end

  def self.color(str, color)
    String.build do |s|
      s << RESET_SEQ << color << str << RESET_SEQ
    end
  end

  def self.star(str)
    self.color(str, STAR_SEQ)
  end

  def self.red(str)
    self.color(str, RED_SEQ)
  end

  def self.dark_red(str)
    self.color(str, DARK_RED_SEQ)
  end

  def self.yellow(str)
    self.color(str, YELLOW_SEQ)
  end

  def self.magenta(str)
    self.color(str, MAGENTA_SEQ)
  end

  ####

  def self.one(str)
    print str
  end

  def self.info(str)
    @@logger.info(yellow(str))
  end

  def self.debug(str)
    @@logger.debug(str)
  end

  def self.error(str)
    @@logger.error(red(str))
  end

  def self.warn(str)
    @@logger.warn(magenta(str))
  end

  def self.fatal(str)
    @@logger.fatal(dark_red(str))
  end
end
