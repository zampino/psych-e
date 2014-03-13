require 'singleton'
require 'ostruct'

module Psych::E
  class Configuration < OpenStruct
    include Singleton

    ALLOWED_OPTIONS = [:emit, :mount, :root, :paranoid]

    DEFAULTS = {
      emit: :ruby,
      root: Dir.pwd
    }

    def self.allowed_keys?
      proc { |key, _|
        ALLOWED_OPTIONS.include?(key)
      }
    end

    def self.update_with local_options
      defaults = instance.to_h.keep_if &allowed_keys?
      options = defaults.merge local_options
      SessionOptions.new(options)
    end

    def initialize
      super(DEFAULTS)
    end

    # flavored options

    # allows a friendlier mount instruction interface

    def mount map=nil
      return super() unless map.is_a?(Hash)
      self.mount= map
    end

    def root
      Pathname.new super()
    end


    def reset
      @table = DEFAULTS
      true
    end
  end

  class SessionOptions < OpenStruct

    # @return (Symbol) :to_ruby, :to_yaml, :to_json
    def emit
      {
        ruby: :to_ruby,
        yaml: :to_yaml,
        json: :to_json,
      }[super]
    end
  end
end
