module Rbedis

  class Datastore

    attr_accessor :database

    def initialize
      @database_file = "#{Configuration.settings[:data_directory]}database.rbedis"
      if File.exists?(@database_file)
        database_string = File.open(@database_file).read
        if !database_string.empty?
          @database = Marshal.load(database_string)
        else
          @database = {}
        end
      else
        @database = {}
      end
    end

    def []=(key, value)
      @database[key] = value
    end

    def get(key)
      @database[key] || nil
    end

    def size
      @database.size
    end

    def delete(key)
      @database.delete(key)
    end

    def flush
      @database = {}
    end

    def has_key?(key)
      @database.has_key?(key)
    end

    def save_database
      string_db = Marshal.dump(@database)
      File.open(@database_file, 'wb') { |f| f.puts string_db }
    end
  end


end