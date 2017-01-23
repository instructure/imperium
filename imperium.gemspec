# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imperium/version'

Gem::Specification.new do |spec|
  spec.name          = 'imperium'
  spec.version       = Imperium::VERSION
  spec.authors       = ['Tyler Pickett']
  spec.email         = ['t.pickett66@gmail.com']

  spec.summary       = %q{A powerful, easy to use, Consul client}
  spec.description   = %q{A powerful, easy to use, Consul client}
  spec.homepage      = 'https://github.com/????/imperium'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'addressable', '~> 2.5.0'
  spec.add_dependency 'httpclient', '~> 2.8'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3.2'
  spec.add_development_dependency 'wwtd', '~> 1.3'
end
