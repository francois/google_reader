# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "google_reader/version"

Gem::Specification.new do |s|
  s.name        = "google_reader"
  s.version     = GoogleReader::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["François Beausoleil"]
  s.email       = ["francois@teksol.info"]
  s.homepage    = "https://github.com/francois/google_reader"
  s.summary     = %q{An unofficial Ruby client for Google Reader }
  s.description = %q{Access Google Reader in a quick and simple way, using plain Ruby.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rest-client", "~> 1.6.1"
  s.add_dependency "nokogiri", "~> 1.4.4"

  s.add_development_dependency "rspec"
end
