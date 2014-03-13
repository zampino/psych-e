class Psych::E::Session
  class Tasks < Hash
    include Celluloid

    def initialize(session)
      @session = session
      async.event_loop
    end

    def event_loop
      event = receive {|msg| msg.is_a?(Psych::E::Session::Event) }
      send "react_on_#{event.id}_event", event.data
      event_loop
    end

    def react_on_add_event key
      Celluloid.logger.info "key added #{key}"
      store(key, true)
    end

    def react_on_done_event key
      Celluloid.logger.info "key deleted #{key}"
      delete(key)
      check_tasks_empty
    end

    def check_tasks_empty
      return unless empty?
      @session.signal :tasks_clean
    end

  end
end
