module Psych::E::Nodes
  class RemoteNode < Psych::Nodes::Node
    extend Forwardable

    attr_reader :remote
    delegate [:class, :children, :root] => "remote.value"

    def initialize(uri, session, options, origin)
      @remote = Psych::E::Resolution.new(uri, session, options: options, parent: origin).fetch_document
    end

  end
end
