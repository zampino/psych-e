module Psych::E
  class Resolution
    module Cache
      # TODO: use active support
      
      def self.storage
        @storage ||= {}
      end

      def self.store(key, value)
        return true
        # cache will be available from v. 0.2.0
        storage[key] = value
        if actor = Celluloid::Actor[key]
          actor.signal :document_cached, value
        end
      end

      def self.get(key)
        storage[key]
      end
    end
  end
end
