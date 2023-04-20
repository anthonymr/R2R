require_relative 'connector'
require_relative 'arguments'

def main()
  args = Arguments.new.arguments

  Connector.new(args[:name], args[:server], args[:port], args[:type]).start
end

main
