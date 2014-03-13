class Psych::E::Resolution
  module Parser
    def parse
      yaml = @env.fetch_yaml
      handler = Psych::E::Handler.new @session, options: @options, origin: @env do |document|
        Cache.store(key, document) # available from version >= 0.2.0
        return document
      end
      Psych::Parser.new(handler).parse yaml
    end
  end
end
