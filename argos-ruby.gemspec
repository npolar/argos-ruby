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
  s.add_development_dependency 'simplecov', '~> 0'

  s.add_dependency 'yajl-ruby', '~> 1'
  s.add_dependency 'uuidtools', '~> 2'
  s.add_dependency 'hashie', '~> 3'
  s.add_dependency 'json-schema', '~> 2'
  
  # ignores = File.readlines('.gitignore').grep(/\S+/).map {|s| s.chomp } + 
  ignores = ['.gitignore', '.rspec', '.travis.yml', '.yardopts']
  s.files = (Dir["**/*"].reject { |f| File.directory?(f) || ignores.any? { |i| File.fnmatch(i, f) } } ).sort
  s.executables  = ["argos-ascii", "argos-soap"]
  
  s.require_paths = ["lib"]
end
