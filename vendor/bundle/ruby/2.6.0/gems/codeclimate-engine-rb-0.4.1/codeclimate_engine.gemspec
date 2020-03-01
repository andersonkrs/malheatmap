# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cc_engine/version'

# rubocop:disable Metrics/LineLength
Gem::Specification.new do |spec|
  spec.name          = "codeclimate-engine-rb"
  spec.version       = CCEngine::VERSION
  spec.authors       = ["Andy Waite"]
  spec.email         = ["github.aw@andywaite.com"]

  spec.summary       = "JSON issue formatter for the Code Climate engine"
  spec.homepage      = "https://github.com/andyw8/codeclimate-engine-rb"
  spec.licenses      = ["MIT"]

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_dependency "virtus", "~> 1.0"
end
# rubocop:enable Metrics/LineLength
