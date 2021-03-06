# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sycamore/version'

Gem::Specification.new do |spec|
  spec.name          = 'sycamore'
  spec.version       = Sycamore::VERSION
  spec.authors       = ['Marcel Otto']
  spec.email         = ['marcelotto@gmx.de']

  spec.summary       = %q{An unordered tree data structure for Ruby.}
  spec.description   = %q{Sycamore is an unordered tree data structure.}
  spec.homepage      = 'https://github.com/marcelotto/sycamore'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yard-doctest', '0.1.7'
end
