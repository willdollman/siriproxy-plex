# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-plex"
  s.version     = "0.0.1" 
  s.authors     = ["willdollman"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{A Siri Proxy Plugin for controlling a Plex media server}
  s.description = %q{A plugin for controlling Plex media players. It intercepts phrases like "play film casino royale" or "plex pause".}

  s.rubyforge_project = "siriproxy-plex"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
