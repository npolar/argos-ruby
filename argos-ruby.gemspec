# encoding: utf-8
# https://github.com/radar/guides/blob/master/gem-development.md

lib = File.expand_path("#{__dir__}/lib")

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "argos/version"

Gem::Specification.new do |s|
  s.name        = "argos-ruby"
  s.version     = Argos::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Espen Egeland", "Conrad Helgeland"]
  s.email       = ["data*npolar.no"]
  s.homepage    = "http://github.com/npolar/argos-ruby"
  s.summary     = %q{Argos CLS satellite tracking library and command-line tools}
  s.description = %q{Argos (http://www.argos-system.org/) webservice client and Argos legacy file (DS/DAT and DIAG/DIA) parser.}
  s.license = "GPL-3.0"

  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'simplecov'

  s.add_dependency 'yajl-ruby'
  s.add_dependency 'uuidtools'
  s.add_dependency 'hashie'
  s.add_dependency 'json-schema'

  #s.files         = `git ls-files`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  
  ignores = File.readlines('.gitignore').grep(/\S+/).map {|s| s.chomp }
  dotfiles = [ '.gitignore', '.rspec', '.travis.yml', '.yardopts' ]
  s.files = (Dir["**/*"].reject { |f| File.directory?(f) || ignores.any? { |i| File.fnmatch(i, f) } } + dotfiles).sort
  
  s.require_paths = ["lib"]
end
