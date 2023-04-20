require 'socket'
require 'io/console'
require 'json'

class Connector
  def initialize(name, hostname, port, type)
    @name = name
    @hostname = hostname
    @port = port
    @type = type

    @history = []
    @mutex = Mutex.new
    @incoming_messages = Queue.new
    @outcoming_messages = Queue.new
    @con = nil
    @server = nil

    @client_accept_thread = nil
    @incoming_message_thread = nil
    @outcoming_message_thread = nil
    @keyboard_thread = nil

    @wellcome_messages = [
      'Connection established!',
      'press ctrl + n to write new message!',
      'send !q to exit!'
    ]
  end

  def start
    if @type == 'client'
      connect_to_server
    else
      create_server
      @client_accept_thread = client_accept_thread
    end

    @keyboard_thread = keyboard_thread
    @incoming_message_thread = incoming_message_thread
    @outcoming_message_thread = outcoming_message_thread

    @keyboard_thread.join
    @incoming_message_thread.join
    @outcoming_message_thread.join
  end

  private

  def close_connection
    @con.puts('Connection reset by peer, send !q to exit!')

    @incoming_message_thread&.kill
    @outcoming_message_thread&.kill

    @con&.close
    @server&.close

    puts 'Goodbye!'
    exit
  end

  def parse_message(msg)
    JSON.parse(msg)
  rescue JSON::ParserError, TypeError
    { 'owner' => 'System', 'message' => msg }
  end

  def create_server
    @server = TCPServer.new(@port)
  end

  def connect_to_server
    @con = TCPSocket.open(@hostname, @port)
  end

  def client_accept_thread
    Thread.new do
      puts 'waiting for client...'

      loop do
        @con = @server.accept
        system('clear') || system('cls')

        @wellcome_messages.each do |message|
          puts " System:  #{message}"
          @history << JSON.generate({ owner: 'System', message: message })
        end

        @con.puts(@wellcome_messages.join("\n"))

        @client_accept_thread.kill
      end
    end
  end

  def incoming_message_thread
    Thread.new do
      @client_accept_thread.join if @type == 'server'
      loop do
        @incoming_messages << @con.gets unless @con.eof?

        next if @incoming_messages.empty?

        @mutex.synchronize do
          msg = @incoming_messages.pop
          @history << msg
          system('clear') || system('cls')

          @history.each do |message|
            hash_message = parse_message(message)
            puts " #{hash_message['owner']}:  #{hash_message['message']}"
          end
        end
      end
    end
  end

  def outcoming_message_thread
    @client_accept_thread.join if @type == 'server'

    loop do
      next if @outcoming_messages.empty?

      @mutex.synchronize do
        msg = JSON.generate(@outcoming_messages.pop)
        @con.puts(msg)
        @history << msg
        system('clear') || system('cls')
        @history.each do |message|
          hash_message = parse_message(message)
          puts " #{hash_message['owner']}:  #{hash_message['message']}"
        end
      end
    end
  end

  def keyboard_thread
    Thread.new do
      @client_accept_thread.join if @type == 'server'

      loop do
        input = $stdin.getch

        if input == "\u000E"
          @mutex.synchronize do
            print '>'
            new_message = gets
            close_connection if new_message == "!q\n"
            @outcoming_messages << { owner: @name, message: new_message }
          end
        end

        close_connection if input == "\u0003"
      end
    end
  end
end
