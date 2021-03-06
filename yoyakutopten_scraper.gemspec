# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yoyakutopten_scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "yoyakutopten_scraper"
  spec.version       = YoyakutoptenScraper::VERSION
  spec.authors       = ["ryysd"]
  spec.email         = ["ry.ysd01@gmail.com"]
  spec.summary       = %q{scraper for https://yoyaku-top10.jp.}
  spec.description   = %q{scraper for https://yoyaku-top10.jp.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'typhoeus'
end
