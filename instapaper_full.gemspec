# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "instapaper_full/version"

Gem::Specification.new do |s|
  s.name        = "instapaper_full"
  s.version     = InstapaperFull::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Biddulph"]
  s.email       = ["mb@hackdiary.com"]
  s.homepage    = "https://github.com/mattb/instapaper_full"
  s.summary     = %q{Wrapper for the Instapaper Full Developer API}
  s.description = %q{See http://www.instapaper.com/api/full}

  s.rubyforge_project = "instapaper_full"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("faraday", ">=0.5.5")
  s.add_dependency("simple_oauth", ">=0.1.4")
  s.add_dependency("yajl-ruby",">=0.8.1")
end
