# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "badges/version"

Gem::Specification.new do |s|
  s.name        = "badges"
  s.version     = Badges::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["kookster"]
  s.email       = ["andrew@beginsinwonder.com"]
  s.homepage    = ""
  s.summary     = %q{Authorization engine}
  s.description = %q{Authorization engine}

  s.rubyforge_project = "badges"

  s.add_dependency("activesupport")

  # specify any dependencies here; for example:
  s.add_development_dependency("rails")
  s.add_development_dependency("rspec-rails")
  s.add_development_dependency("sqlite3")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
