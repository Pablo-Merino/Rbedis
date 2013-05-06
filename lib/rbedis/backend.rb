module Rbedis
  class Backend
    
    require 'rbconfig'
    require 'eventmachine'
    require 'optparse'

    def initialize(argv)

      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: #{__FILE__} [options]"

        opts.on("-c file", "--config file", String, "Specify config file") do |file|
          options[:config] = file
        end
      end.parse!

      Logger.info "Rbedis 0.0.1 -- boot time: #{Time.now}"

      load "#{File.expand_path(options[:config])}"

      @datastore = Datastore.new   

      @password = Configuration.settings[:password]

      EventMachine.run {
        @server_em_instance = EventMachine.start_server Configuration.settings[:address] || "0.0.0.0", Configuration.settings[:port]  || 6379, Connection, self
      }
    end

    def execute_command(parsed_array, peer_info, client)
      arguments = parsed_array.dup
      arguments.shift
      Logger.info "#{peer_info.join(":")} -- #{parsed_array[0].to_s} #{arguments.join(" ")}"
      if !@password.nil?
        if client.authed
          actually_interpret_commands(parsed_array, arguments)
        else
          if ["quit", "auth"].include?(parsed_array[0].to_s)
            actually_interpret_commands(parsed_array, arguments, client)
          else
            "-ERR operation not permitted"
          end
        end
      else
        actually_interpret_commands(parsed_array, arguments)
      end

    end

    def actually_interpret_commands(parsed_array, *arguments)

      response = self.send("redis_#{parsed_array[0].to_s}", arguments)
      @datastore.save_database
      response
    end

    def redis_set(*values)
      values.flatten!
      if values.size == 2
        @datastore[values[0]] = values[1]
        "+OK"
      else
        "-ERR wrong number of arguments for 'set' command"
      end
    end

    def redis_get(*values)
      values.flatten!
      if values.size == 1
        result = @datastore.get(values[0])
        if result.nil?
          "$-1"
        else
          "$#{result.bytesize}\r\n#{result.to_s}"
        end
      else
        "-ERR wrong number of arguments for 'get' command"
      end
    end

    def redis_info(*values)
      values.flatten!
      if values.size == 0
        response = ["redis_version:rbedis0.0.1","os:#{RbConfig::CONFIG['host_os']}"].join("\r\n")
        "$#{response.bytesize}\r\n#{response}"
      else
        "-ERR wrong number of arguments for 'info' command"
      end
    end

    def redis_ping(*values)
      values.flatten!
      if values.size == 0
        "+PONG"
      else
        "-ERR wrong number of arguments for 'ping' command"
      end
    end

    def redis_time(*values)
      values.flatten!
      if values.size == 0
        now = Time.now
        response_array = ["$#{now.to_i.to_s.bytesize}\r\n#{now.to_i}", "$#{now.strftime("%6N").size}\r\n#{now.strftime("%6N")}"]
        "*#{response_array.count}\r\n#{response_array.join("\r\n")}"
      else
        "-ERR wrong number of arguments for 'time' command"
      end
    end

    def redis_dbsize(*values)
      values.flatten!
      if values.size == 0
        ":#{@datastore.size}"
      else
        "-ERR wrong number of arguments for 'dbsize' command"
      end
    end

    def redis_del(*values)
      values.flatten!
      if values.size == 1
        @datastore.delete(values[0])
        ":1"
      else
        "-ERR wrong number of arguments for 'del' command"
      end

    end

    def redis_incr(*values)
      values.flatten!
      if values.size == 1
        value = @datastore.get(values[0])
        if value.is_number?
          @datastore[values[0]] = (@datastore.get(values[0]).to_i + 1).to_s
          ":#{@datastore.get(values[0])}"
        else
          "-ERR value is not an integer or out of range"
        end
      else
        "-ERR wrong number of arguments for 'incr' command"
      end
    end

    def redis_incrby(*values)
      values.flatten!
      if values.size == 2
        value = @datastore.get(values[0])
        if value.is_number?
          @datastore[values[0]] = (@datastore.get(values[0]).to_i + values[1].to_i).to_s
          ":#{@datastore.get(values[0])}"
        else
          "-ERR value is not an integer or out of range"
        end
      else
        "-ERR wrong number of arguments for 'incrby' command"
      end
    end

    def redis_decr(*values)
      values.flatten!
      if values.size == 1
        value = @datastore.get(values[0])
        if value.is_number?
          @datastore[values[0]] = (@datastore.get(values[0]).to_i - 1).to_s
          ":#{@datastore.get(values[0])}"
        else
          "-ERR value is not an integer or out of range"
        end
      else
        "-ERR wrong number of arguments for 'decr' command"
      end
    end

    def redis_decrby(*values)
      values.flatten!
      if values.size == 2
        value = @datastore.get(values[0])
        if value.is_number?
          @datastore[values[0]] = (@datastore.get(values[0]).to_i - values[1].to_i).to_s
          ":#{@datastore.get(values[0])}"
        else
          "-ERR value is not an integer or out of range"
        end
      else
        "-ERR wrong number of arguments for 'decrby' command"
      end
    end

    def redis_append(*values)
      values.flatten!
      if values.size == 2
        value = @datastore.get(values[0])
        @datastore[values[0]] = (@datastore.get(values[0]) << values[1].to_s).lstrip
        ":#{@datastore.get(values[0]).bytesize}"
      else
        "-ERR wrong number of arguments for 'append' command"
      end
    end

    def redis_strlen(*values)
      values.flatten!
      if values.size == 1
        result = @datastore.get(values[0])
        if result.nil?
          ":0"
        else
          ":#{result.size}"
        end
      else
        "-ERR wrong number of arguments for 'strlen' command"
      end
    end

    def redis_echo(*values)
      values.flatten!
      if values.size == 1
        "$#{values.flatten[0].bytesize}\r\n#{values[0]}"
      else
        "-ERR wrong number of arguments for 'echo' command"
      end
    end

    def redis_quit(*values)
      :close_client
    end

    def redis_flushdb(*values)
      values.flatten!
      if values.size == 0
        @datastore.flush
        "+OK"
      else
        "-ERR wrong number of arguments for 'echo' command"
      end
    end

    def redis_shutdown(*values)
      values.flatten!
      if values.size == 0
        exit
      else
        "-ERR syntax error"
      end
    end

    def redis_exists(*values)
      values.flatten!
      if values.flatten.size == 1
        if @datastore.has_key?(values[0])
          ":1"
        else
          ":0"
        end
      else
        "-ERR wrong number of arguments for 'exists' command"
      end
    end

    def redis_save(*values)
      values.flatten!
      if values.size == 0
        Logger.info "(#{Time.now}) Synchronously saving database..."
        @datastore.save_database
        "+OK"
      else
        "-ERR wrong number of arguments for 'save' command"
      end
    end

    def redis_bgsave(*values)
      values.flatten!
      if values.size == 0
        saving_thread = Thread.new do
          Logger.info "(#{Time.now}) Asynchronously saving database..."
          @datastore.save_database
          Logger.info "(#{Time.now}) Finished async save..."
        end
        "+Background saving started"
      else
        "-ERR wrong number of arguments for 'save' command"
      end
    end

    def redis_auth(*values)
      values.flatten!
      if values.size == 2
        if values[0] == @password
          values[1].authed = true
          "+OK"
        else
          "-ERR incorrect password"
        end
      else
        "-ERR wrong number of arguments for 'auth' command"
      end
    end

    def method_missing(m, *args, &block)
      if m =~ /^redis_(.*)/
        puts "#{$1} is not yet implemented!"
        "-ERR command not yet implemented '#{$1}'"
      else
        super
      end
    end

  end

end