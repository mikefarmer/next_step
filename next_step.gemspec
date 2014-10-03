# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'next_step/version'

Gem::Specification.new do |spec|
  spec.name          = "next_step"
  spec.version       = NextStep::VERSION
  spec.authors       = ["Mike Farmer"]
  spec.email         = ["mike.farmer@gmail.com"]
  spec.summary       = %q{ Make it simple to process a series of steps with some surrounding handling }
  spec.description   = %q{ 
     Provides the StepRunner and EventProcessor includes to allow running methods in a series
     of steps and raise certain events based on the outcome of the methods.
                          }
  spec.homepage      = "https://github.com/mikefarmer/next_step"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
