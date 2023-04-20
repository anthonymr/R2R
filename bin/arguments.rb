require 'optparse'

class Arguments
  attr_reader :arguments

  def initialize
    @arguments = parse_arguments
    validate_arguments(@arguments)
  end

  private

  def parse_arguments
    server_description = 'Server to connect, default:localhost, only localhost or IP are accepted'

    arguments = {}

    OptionParser.new do |opt|
      opt.on('-t', '--type TYPE', 'The type of the connection (client/server)') { |o| arguments[:type] = o }
      opt.on('-s', '--server [SERVER]', server_description) { |o| arguments[:server] = o }
      opt.on('-p', '--port PORT', 'The port number') { |o| arguments[:port] = o }
      opt.on('-n', '--name NAME', 'The name of the user') { |o| arguments[:name] = o }
    end.parse!

    arguments
  end

  def validate_arguments(arguments)
    raise 'Type must be client or server!' unless %w[client server].include?(arguments[:type])

    return if arguments[:type] == 'server'

    return if arguments[:server] == 'localhost'

    if arguments[:server].nil?
      arguments[:server] = 'localhost'
      return
    end

    raise 'Invalid IP address!' if @arguments[:server] !~ /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/
  end
end
