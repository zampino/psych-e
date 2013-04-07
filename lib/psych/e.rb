require "psych/e/version"
require "celluloid"

require_relative "e/configuration"
require_relative "e/supervisor"
require_relative "e/resolution"

module Psych
  module E

    def self.configure
      yield Configuration.instance
    end

    def self.resolve(uri, options)
      _options = Configuration.merge(options)
      superv = Supervisor.new(uri, options)
      resolution = Resolution.new(uri, superv)
      stream = resolution.fetch_stream!
      superv.on_tasks_completed do
        stream.public_send _options[:emit]
      end
    end

  end
end
