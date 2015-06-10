# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'winever/version'

Gem::Specification.new do |spec|
  spec.name          = "winever"
  spec.version       = Winever::VERSION
  spec.authors       = ["Maxime Handfield Lapointe"]
  spec.email         = ["hunter_spawn@hotmail.com"]
  spec.description   = %q{Clean ruby syntax for writing and deploying tasks in Windows' task scheduler. Extension of gem whenever.}
  spec.summary       = %q{Add tasks in Windows' task scheduler from a ruby configuration file.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "whenever", ">= 0.9.1"
  spec.add_dependency "highline", ">= 0.5.0"
  spec.add_dependency "win32-taskscheduler", ">= 0.3.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
