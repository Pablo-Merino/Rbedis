module Rbedis
  class Parser

    def initialize(string)
      @string = string.gsub(/^(\$.*\r\n)/, "").gsub(/^(\*.*\r\n)/, "").split("\r\n")
      @string = @string.join(" ")
    end

    def parse
      parsed_message = @string.split(/^([^\s]*)[\s]?([^\s]*)[\s]?([^\s]*)/i)
      parsed_message.reject! { |c| c.empty? }
      parsed_message[0] = parsed_message[0].downcase.to_sym
      parsed_message
    end

  end
end