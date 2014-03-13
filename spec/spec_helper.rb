require 'bundler/setup'
Bundler.require :test

require 'psych/e'

FIXTURES_ROOT = File.expand_path("fixtures", __dir__)
SUPPORT_ROOT = File.expand_path("support", __dir__)

Dir["#{__dir__}/support/**/*.rb"].each {|file| require file }

RSpec.configure do |c|
  c.include Helpers
  c.include CustomMatchers

  c.filter_run_excluding broken: true
end
