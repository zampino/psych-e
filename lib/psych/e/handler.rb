require_relative 'nodes/remote_node'

module Psych::E
  class Handler < Psych::Handlers::DocumentStream

    attr_reader :key, :document

    def initialize key, session, origin: nil, **options, &block
      @key = key
      @session = session
      @origin = origin
      super &block
    end

    def scalar value, anchor, tag, plain, quoted, style
      return super unless tag == "!ref"
      Psych::E::Nodes::RemoteNode.new(value, @session, @origin)
    end

  end
end
