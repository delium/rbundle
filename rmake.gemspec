# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rmake/version'

Gem::Specification.new do |spec|
  spec.name          = "rmake"
  spec.version       = Rmake::VERSION
  spec.authors       = ["Simon"]
  spec.email         = ["simonroy@thoughtworks.com"]
  spec.description   = %q{A bundler for R}
  spec.summary       = %q{Manages your R installation and packages}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rinruby"
  spec.add_development_dependency "json"

  spec.add_runtime_dependency "rinruby"
  spec.add_runtime_dependency "json"
end
