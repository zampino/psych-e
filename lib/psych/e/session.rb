module Psych::E
  class Session
    extend Forwardable
    include Celluloid

    delegate [:info, :debug, :warn, :error] => Celluloid::Logger

    def initialize(**options)
      @options = options
      @event_loop_started = false
    end

    def task_done(key)
      current_actor.mailbox << Event.new(:done, key)
    end

    def enqueue_task(key)
      start_event_loop unless @event_loop_started
      current_actor.mailbox << Event.new(:add, key)
    end

    def on_tasks_completed
      debug "waiting for tasks to be completed"
      wait :tasks_clean if @event_loop_started
      info 'tasks clean!'
      yield
    ensure
      terminate if current_actor.alive?
    end

    private

    def start_event_loop
      async(:event_loop, {})
      @event_loop_started = true
    end

    def event_loop state
      event = receive {|msg| msg.is_a?(Psych::E::Session::Event) }
      state = send "react_on_#{event.id}_event", event.data, state
      event_loop state
    end

    def react_on_add_event key, state
      info "key added #{key}"
      state.store(key, true)
      state
    end

    def react_on_done_event key, state
      info "key deleted #{key}"
      state.delete(key)
      check_tasks_empty state
      state
    end

    def check_tasks_empty state
      current_actor.signal(:tasks_clean) if state.empty?
    end

    Event = Struct.new(:id, :data)
    CircularDependencies = Class.new(StandardError)
  end
end
