# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rmake/version'

Gem::Specification.new do |spec|
  spec.name          = 'rmake'
  spec.version       = Rmake::VERSION
  spec.authors       = ['Simon']
  spec.email         = ['simon@delium.co']
  spec.description   = %q{A bundler for R}
  spec.summary       = %q{Installs R package dependencies with versions}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
