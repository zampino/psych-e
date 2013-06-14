# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'psych/e/version'

Gem::Specification.new do |spec|
  spec.name          = "psych-e"
  spec.version       = Psych::E::VERSION
  spec.authors       = ["Andrea Amantini"]
  spec.email         = ["lo.zampino@gmail.com"]
  spec.description   = %q{The missing _E_ nvironment in Psych}
  spec.summary       = %q{Psyc::E uses Celluloid to asynchronously merge Psych parse trees retrieved from a Rack, Web or filesystem environment}
  spec.homepage      = "https://github.com/zampino/psych-e"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "celluloid"
  spec.add_runtime_dependency "rack"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
end
