require 'open-uri'
require 'pathname'

require_relative 'environment/rack_handler'
require_relative 'environment/fs'

module Psych::E
  class Environment
    extend Forwardable

    attr_reader :location, :uri, :local, :resolved_uri, :key, :parent
    delegate :fragment => :uri

    def initialize(location, options, body: nil, parent: nil)
      @location = location
      @parent = parent
      @root = options.root
      @body = body
      @uri = URI.parse(location)
      @resolved_uri = resolve_uri
      @local = resolve_local
      @key = keyfy
      @rack_handler = RackHandler.new(options)
    end

    def fetch_yaml
      @body || remote_fetch_yaml
    end

    def remote_fetch_yaml
      handle_absolute_uri || handle_through_rack
    end

    def handle_absolute_uri
      return false unless resolved_uri
      resolved_uri.open.read
    end

    def handle_through_rack
      @rack_handler.get(local.to_s)
    end

    # resolved uri is assumed to be always absolute
    def resolve_uri
      return uri if uri.absolute?
      parent.resolved_uri + uri if parent && parent.resolved_uri
    end

    def resolve_local
      path = Pathname.new location
      return path if path.absolute?
      if parent
        resolve_path_name(parent.local, path)
      else
        path
      end
    end

    def resolve_path_name(base, path)
      base.dirname + path
    end

    def keyfy
      path = if resolved_uri
             then resolved_uri.path
             else local.to_s
             end
      ["home", path.split("/")].flatten.reject(&:empty?).join("_")
    end

  end
end
