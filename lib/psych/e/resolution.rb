require_relative 'cache'
require_relative 'resolution/traversable'
require_relative 'resolution/parser'
require_relative 'resolution/dispatch'

module Psych::E
  class Resolution
    include Traversable
    include Parser

    attr_reader :key, :fragment

    def initialize uri, session, body: nil, options: {}, parent: nil
      @session = session
      @options = options
      @env = Environment.new(uri, options, body: body, parent: parent)
      @key = @env.key
      @fragment = @env.fragment
    end

    def fetch_document
      if cached = Cache.get(key) # No need to spawn an actor
        return wrapped(traverse(cached, fragment))
      end
      # status = @session.status(key)
      status = :missing
      dispatch.send "fetch_#{status}_document"
    end

    def fetch_home
      parse
    end

    private

    # in case two uri has the same path but different
    # fragments

    def dispatch
      # Celluloid::Actor[key] || # NOT SURE IT'S NEEDED
      Dispatch.supervise_as(key, @session, @options, @env)[key]
    end

    # to uniform with Celluloid::Future#value
    def wrapped(document)
      Wrapper.new document
    end

    Wrapper = Struct.new(:value)
    FetchError = Class.new(RuntimeError)
  end
end
