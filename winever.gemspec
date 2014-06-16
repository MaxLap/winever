# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'winever/version'

Gem::Specification.new do |spec|
  spec.name          = "winever"
  spec.version       = Winever::VERSION
  spec.authors       = ["Maxime Handfield Lapointe"]
  spec.email         = ["hunter_spawn@hotmail.com"]
  spec.description   = %q{Make it possible to use the Whenever gem's clean ruby syntax for writing and deploying tasks in the windows scheduler, using the same schedule file.}
  spec.summary       = %q{Make it possible to use the Whenever gem on Windows.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "whenever", ">= 0.9.1"
  spec.add_dependency "highline", ">= 0.5.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
