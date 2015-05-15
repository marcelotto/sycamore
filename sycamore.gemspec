# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sycamore/version'

Gem::Specification.new do |spec|
  spec.name          = 'sycamore'
  spec.version       = Sycamore::VERSION
  spec.authors       = ['Marcel Otto']
  spec.email         = ['marcelotto@gmx.de']

  spec.summary       = %q{A pure Ruby implementation of a tree data structure of immutable values.}
  spec.description   = %q{Sycamore is an implementation of an unordered tree data structure of immutable values solely based on Ruby Hashes.}
  spec.homepage      = 'https://github.com/marcelotto/sycamore'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  # end

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'yard', '~> 0.8'
end
