require 'singleton'
require 'ostruct'

module Psych::E
  class Configuration < OpenStruct

    include Singleton

    # def self.defaults
    #   @defaults ||= new
    # end

    def self.merge local_options
      instance.to_h.merge local_options
    end

    def initialize
      super emit: :yaml
    end

    def to_h
      super
    rescue MethodMissing
      @table
    end

    def emit type
      send(:"emit=", type) 
    end

  end
end
