# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feedme_youtubes/version'

Gem::Specification.new do |spec|
  spec.name          = "feedme_youtubes"
  spec.version       = FeedmeYoutubes::VERSION
  spec.authors       = ["Rob Wilson"]
  spec.email         = ["roobert@gmail.com"]
  spec.summary       = %q{monitor youtubes upload feeds for new videos and provide various interfaces to the results}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "http://github.com/roobert/feedme_youtubes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
