require 'singleton'
require 'ostruct'

module Psych::E
  class Configuration < OpenStruct
    include Singleton

    DEFAULTS = {
      emit: :ruby,
      root: Dir.pwd
    }

    def self.allowed_keys
      proc { |key, _|
        [:emit, :mount, :root, :paranoid].include?(key)
      }
    end

    def initialize
      super(DEFAULTS)
    end

    # flavored options

    # allows a friendlier mount instruction interface

    def mount map=nil
      return super() unless map
      self.mount= map
    end

    def root
      Pathname.new super
    end
    
    def self.update_with local_options
      defaults = instance.to_h.keep_if &allowed_keys
      options = defaults.merge local_options
      SessionOptions.new(options)
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
