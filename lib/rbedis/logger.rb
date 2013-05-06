module Rbedis
  module Logger

    require 'colored'
    # log-level constant
    FATAL, ERROR, WARN, INFO, DEBUG, CREATED = 1, 2, 3, 4, 5, 6

    @debug = true

    attr_accessor :level

    def self.close
      @log.close if @opened
      @log = nil
    end

    def self.log(level, data)
      if level == DEBUG && @debug || level != DEBUG
        @level = level
        puts "#{data}\n"
      end
    end

    def self.<<(obj)
      log(INFO, obj.to_s)
    end

    def self.fatal(msg)   log   FATAL,    "[#{"FATAL".red}] "     << format(msg); end
    def self.error(msg)   log   ERROR,    "[#{"ERROR".red}] "     << format(msg); end
    def self.warn(msg)    log   WARN,   "[#{"WARN".red_on_yellow}]  " << format(msg); end
    def self.info(msg)    log   INFO,   "[#{"INFO".green}]  "       << format(msg); end
    def self.debug(msg)   log   DEBUG,    "[#{"DEBUG".red_on_yellow}] " << format(msg); end
    def self.created(msg) log   CREATED,  "[#{"CREATED".green}] "     << format(msg); end

    def self.fatal?; @level >= FATAL; end
    def self.error?; @level >= ERROR; end
    def self.warn?; @level >= WARN; end
    def self.info?; @level >= INFO; end
    def self.debug?; @level >= DEBUG; end
    def self.created?; @level >= CREATED; end

    private

    def self.format(arg)
      str = if arg.is_a?(Exception)
        "#{arg.class}: #{arg.message}\n\t" <<
        arg.backtrace.join("\n\t") << "\n"
      elsif arg.respond_to?(:to_str)
        arg.to_str
      else
        arg.inspect
      end
    end
  end
end