module Psych::E
  class Resolution
    module Cache
      # TODO: use active support
      
      @store ||= {}

      def self.fetch(key)
        @store[key]
      end
      
      def self.exists?(key)
        @store.key? key
      end
    end
  end
end
