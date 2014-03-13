require_relative 'session/tasks'

module Psych::E
  class Session
    extend Forwardable
    include Celluloid

    delegate [:info, :debug, :warn, :error] => Celluloid::Logger
    attr_reader :options, :tasks

    def initialize
      @options = options
      @tasks = Tasks.new_link(current_actor)
    end

    def status(key)
      tasks.has_key?(key) ? :queued : :missing
    end

    def enqueued_tasks
      tasks.keys
    end

    def tasks_empty?
      tasks.empty?
    end

    def task_done(key)
      tasks.mailbox << Event.new(:done, key)
    end

    def enqueue_task(key)
      raise CircularDependencies if circular_dependencies?(key)
      tasks.mailbox << Event.new(:add, key)
    end

    # blocking phase
    def on_tasks_completed
      debug "waiting for tasks to be completed"
      wait :tasks_clean unless tasks.empty?
      info 'tasks clean!'
      yield
    ensure
      tasks.terminate if tasks.alive?
      terminate if current_actor.alive?
    end

    private

    def circular_dependencies?(key)
      # circular deps detection in VERSION > 0.8.0
      false
    end

    Event = Struct.new(:id, :data)
    CircularDependencies = Class.new(StandardError)
  end
end
