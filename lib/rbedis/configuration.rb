module Rbedis

  module Configuration

    extend self

    def self.configure(&block)
      instance_eval(&block)
    end

    def settings  
      @settings ||= Hash.new  
    end

    def port(port=6379)
      settings[:port] = port
    end

    def address(address="0.0.0.0")
      settings[:address] = address
    end

    def password(password="")
      settings[:password] = password
    end

    def data_directory(data_directory="~/rbedis")
      settings[:data_directory] = data_directory << '/' unless data_directory.end_with?('/')
    end

  end

end