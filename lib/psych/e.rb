require "psych/e/version"
require "psych"
# require "celluloid/autostart"
require "celluloid"
require "forwardable"
# require "active_support/core_ext/module/delegation"

require_relative "e/configuration"
require_relative "e/session"
require_relative "e/resolution"
require_relative "e/environment"
require_relative "e/handler"

module Psych
  module E

    def self.load(body, uri: ".", **options)
      resolve(uri, body: body, emit: :ruby, **options)
    end

    # NOTE: possibly inconsistent with #resolve
    #       should maybe be aliased
    def self.load_file(path, uri: ".", **options)
      load(open(path).read, uri: uri, **options)
    end

    def self.resolve(uri=".", body: nil, **options)
      Celluloid.start # Start the StarSystem
      _options = Configuration.update_with(options)
      session = Session.new(uri, _options)
      resolution = Resolution.new(uri, session, body: body)
      home = resolution.fetch_home
      session.on_tasks_completed do
        home.send _options[:emit]
      end
    end

    def self.configure
      yield Configuration.instance
    end

  end
end
