# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aikatsu_calendar/version'

Gem::Specification.new do |spec|
  spec.name          = "aikatsu_calendar"
  spec.version       = AikatsuCalendar::VERSION
  spec.authors       = ["furugomu"]
  spec.email         = ["furugomu@gmail.com"]
  spec.description   = %q{Aikatsu calendar}
  spec.summary       = %q{Ai! Katsu!}
  spec.homepage      = "https://github.com/furugomu/aikatsu_calendar"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
