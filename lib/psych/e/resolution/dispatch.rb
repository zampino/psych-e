class Psych::E::Resolution
  class Dispatch
    include Celluloid
    include Traversable
    include Parser

    finalizer :notify_session

    attr_reader :key, :fragment

    def initialize(session, env)
      @session = session
      @env = env
      @key = @env.key
      @fragment = @env.fragment
    end

    def fetch_missing_document
      @session.enqueue_task key #, origin: @env
      future :_fetch_document
    end

    def fetch_queued_document
      future :wait_cached
    end

    def _fetch_document
      doc = parse.document
      traverse(doc, fragment)
    ensure
      terminate
    end

    def wait_cached
      doc = wait :document_cached
      traverse(doc, fragmnet)
    end

    def notify_session
      @session.task_done key
    end

  end
end
