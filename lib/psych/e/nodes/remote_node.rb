module Psych::E::Nodes
  class RemoteNode < Psych::Nodes::Node
    extend Forwardable
    attr_reader :remote
    delegate [:class, :children] => "remote.value"

    def initialize(uri, session, origin)
      super()
      @remote = Psych::E::Resolution.new(uri, session, parent: origin).fetch_document 
    end

  end
end
