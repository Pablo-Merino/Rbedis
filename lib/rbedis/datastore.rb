module Rbedis

  class Datastore

    attr_accessor :database

    def initialize
      @current_database = 0
      @database_file = "#{Configuration.settings[:data_directory]}database.rbedis"
      if File.exists?(@database_file)
        database_string = File.open(@database_file).read
        if !database_string.empty?
          @database = Marshal.load(database_string)
        else
          @database = {0 => {}}
        end
      else
        @database = {0 => {}}
      end
    end

    def []=(key, value)
      @database[@current_database][key] = value
    end

    def get(key)
      @database[@current_database][key] || nil
    end

    def size
      @database[@current_database].size
    end

    def delete(key)
      @database[@current_database].delete(key)
    end

    def flush
      @database[@current_database] = {}
    end

    def has_key?(key)
      @database.has_key?(key)
    end

    def switch_db(index)
      @current_database = index.to_i
      if !@database.has_key?(index.to_i)
        @database[@current_database] = {} 
      end
    end

    def save_database
      string_db = Marshal.dump(@database)
      File.open(@database_file, 'wb') { |f| f.puts string_db }
    end
  end


end