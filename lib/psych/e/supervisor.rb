module Psych::E
  class Supervisor
    include CallbackApi

    attr_reader :home_options
    
    def initialize(uri, options)
      @home_options = options
      @home_key = keyfy uri
      @tasks = {}
      on(:done) do |info|
        @tasks.delete info[:task_id]
      end
    end

    def status key
      @tasks.key?(key) ? :queued : :missing
    end

    def enqueue key, meta = {}
      raise CircularDependencies if circular_dependencies?(key)
      @tasks[key] = meta
    end

    def on_tasks_completed
      yield
    end

    private

    def keyfy uri
      uri
    end

    def circular_dependencies?(key)
      # circular deps detection in VERSION > 0.8.0
      false
    end

    CircularDependencies = Class.new(StandardError)
  end
end
