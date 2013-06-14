require 'bundler/setup'
Bundler.require :test

require 'psych/e'

FIXTURES_ROOT = File.expand_path("fixtures", __dir__)

Dir["#{__dir__}/support/**/*.rb"].each {|file| require file }

RSpec.configure do |c|
  c.include Helpers
  c.include CustomMatchers
end
