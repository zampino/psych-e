require_relative 'resolution/cache'

module Psych::E
  class Resolution
    include Celluloid
    include Traversable

    attr_reader :key, :fragment
    
    def initialize(uri, superv, origin = nil)
      @superv = superv
      @env = Environment.new(uri)
      @key = @env.key
      @fragment = @env.fragment
    end

    def fetch_document
      cached = cached?(key) 
      return traverse(cached, fragment) if cached
      status = @superv.status key
      send :"fetch_#{status}_document"
    end

    def fetch_stream
      parse.stream
    end

    private

    def _fetch_document
      @superv.enqueue key, origin
      doc = parse.document
      result = traverse(doc, fragment)
      @superv.trigger :done, task_id: key
      result
    end

    def cached?(key)
      Cache.fetch(key)
    end

    def fetch_missing_document
      # @superv.enqueue key, origin  # maybe moce inside _fetch_doc
      current_actor.future :_fetch_document
    end

    def fetch_queued_document
      current_actor.future :wait_cached
    end

    def parse
      yaml = @env.fetch_yaml
      handler = Handler.new(@superv, key)
      Psych::Parser.new(handler).parse yaml
      handler
    end

    def wait_cached
      loop do
        break Cache.fetch(key) if Cache.exists?(key)
      end
    end
    
    FetchError = Class.new(RuntimeError)
  end
end
