# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ad-framework/version"

Gem::Specification.new do |s|
  s.name        = "ad-framework"
  s.version     = Ad::Framework::VERSION
  s.authors     = ["Collin Redding", "Matt McPherson"]
  s.homepage    = "http://github.com/teaminsight/ad-framework"
  s.summary     = %q{A framework for defining an ActiveDirectory schema in ruby.}
  s.description = %q{A framework for defining an ActiveDirectory schema in ruby.}

  s.rubyforge_project = "ad-framework"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "ad-ldap", "~>0.1.1"

  s.add_development_dependency "assert",  "~>0.3.0"
  s.add_development_dependency "log4r",   "~>1.1.9"
  s.add_development_dependency "mocha",   "~>0.9.12"
end
