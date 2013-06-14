require 'rack'

class Psych::E::Environment
  class RackHandler 
    def initialize(options)
      # @paranoid = options.paranoid
      root = options.root
      map = { "/" => FS.new(root) }
      if app_or_map = options.mount
        map = if app_or_map.is_a?(Hash)
              then map.merge(app_or_map)
              else {"/" => app_or_map}
              end
      end
      @url_map = Rack::URLMap.new(map)
    end

    def get(uri)
      response = Rack::MockRequest.new(@url_map).get(uri)
      # check_headers if @paranoid
      response.body
    end

  end
end
