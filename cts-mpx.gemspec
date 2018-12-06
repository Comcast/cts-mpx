lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cts/mpx/version'

Gem::Specification.new do |spec|
  spec.name          = "cts-mpx"
  spec.version       = Cts::Mpx::VERSION
  spec.authors       = ["Ernie Brodeur"]
  spec.email         = ["ernest.brodeur@cable.comcast.net"]

  spec.summary       = "Ruby bindings for MPX services."
  spec.description   = "."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.4.0'

  spec.add_runtime_dependency "creatable", "~> 2.2.0"
  spec.add_runtime_dependency "excon"
  spec.add_runtime_dependency "oj", "3.5.0"

  spec.add_development_dependency 'bump'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "erubis"
  spec.add_development_dependency "gli"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-rubocop"
  spec.add_development_dependency "guard-yard"
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", "~>0.52.1"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-console"
  spec.add_development_dependency "solargraph"
  spec.add_development_dependency "yard"
end
