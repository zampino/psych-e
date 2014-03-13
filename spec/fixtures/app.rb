require 'sinatra'
require 'yaml'

class App < Sinatra::Application
  helpers do
    def some_content
      {
        james: { doesnt: { like: "Jaegermeister", but: "Averna a lot"}}
      }
    end
  end

  get "/for_yaml" do
    content_type "x-application/yaml"
    YAML.dump some_content
  end
end
