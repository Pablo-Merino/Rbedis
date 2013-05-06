module Rbedis
  class Connection < EM::Connection
    attr_accessor :authed
    def initialize(backend)
      @backend = backend
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      @peer_info = [ip, port]
      Logger.info "Client connected to the server (#{ip}:#{port})"
      @authed = false
    end

    def receive_data data
      @buf = ''
      @buf << data
      if @buf =~ /^.+?\r?\n/
        commands = Parser.new(@buf).parse
        result = @backend.execute_command(commands,@peer_info, self)
        if result == :close_client
          send_data "+OK\r\n"
          close_connection_after_writing
        else
          send_data result << "\r\n"
        end
      end
    end

    def unbind
      Logger.info "Client disconnected from the server"
    end
  end
end