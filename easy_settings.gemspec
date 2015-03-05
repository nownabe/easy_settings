# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "easy_settings"

Gem::Specification.new do |spec|
  spec.name          = "easy_settings"
  spec.version       = EasySettings::VERSION
  spec.authors       = ["nownabe"]
  spec.email         = ["nownabe@gmail.com"]
  spec.summary       = %q{EasySettings is a simple settings with YAML file.}
  spec.homepage      = "https://github.com/nownabe/easy_settings"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
