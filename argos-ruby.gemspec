# encoding: utf-8
# https://github.com/radar/guides/blob/master/gem-development.md
require File.expand_path(File.dirname(__FILE__)+"/lib/argos")

Gem::Specification.new do |s|
  s.name        = "argos-ruby"
  s.version     = Argos::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Espen Egeland", "Conrad Helgeland"]
  s.email       = ["data*npolar.no"]
  s.homepage    = "http://github.com/npolar/argos-ruby"
  s.summary     = %q{Argos satellite tracking data parsers}
  s.description = %q{Parses Argos (http://www.argos-system.org/) DS/DAT and DIAG/DIA files.}
  s.license = "GPL-3.0"
  s.add_development_dependency "rspec"
  s.files         = `git ls-files`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
