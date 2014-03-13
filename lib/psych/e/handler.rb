require_relative 'nodes/remote_node'

module Psych::E
  class Handler < Psych::Handlers::DocumentStream

    attr_reader :key, :document

    def initialize session, origin: nil, options: {}, &block
      @options = options
      @session = session
      @origin = origin
      super &block
    end

    def scalar value, anchor, tag, plain, quoted, style
      return super unless tag == "!ref"
      s = Psych::E::Nodes::RemoteNode.new(value, @session, @options, @origin)
      s.tap {|node| @last.children << node }
    end
  end
end
