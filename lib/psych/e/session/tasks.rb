class Psych::E::Session
  class Tasks
    include Celluloid

    attr_reader :tasks_set

    def initialize(session)
      @session = session
      @tasks_set = {}
      async.event_loop
    end

    def keys
      @tasks_set.keys
    end

    def has_key?(key)
      @tasks_set.has_key?(key)
    end

    def event_loop
      # @session.info "tick"
      event = receive {|msg| msg.is_a?(Psych::E::Session::Event) }
      # @session.info "processing #{event.id}"
      send "react_on_#{event.id}_event", event.data
      event_loop
    end

    def react_on_add_event key
      Celluloid.logger.info "key added #{key}"
      @tasks_set[key] = true
    end
    
    def react_on_done_event key
      Celluloid.logger.info "key deleted #{key}"
      @tasks_set.delete(key)
      check_tasks_empty
    end

    def check_tasks_empty
      return unless @tasks_set.empty?
      @session.signal :tasks_clean
    end

  end
end
