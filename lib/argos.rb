require "bundler/setup"
require "bigdecimal"
require "date"
require "time" # for iso8601
require "digest/sha1"
require "json"
require "logger"
require "cgi"

require_relative "argos/exception"
require_relative "argos/ascii"
require_relative "argos/ds"
require_relative "argos/diag"
require_relative "argos/soap"
#require_relative "argos/download"

# Argos library containg
# * Parsers for Argos legacy ASCII files (DS/DAT and DIAG files)
# * Soap web service client and Argos XML download tool
#
# https://github.com/npolar/argos-ruby
#
# Code written by staff at the [Norwegian Polar Data Centre](http://data.npolar.no),
# [Norwegian Polar Institute](http://npolar.no)
# 
# For information about Argos, see: http://www.argos-system.org
module Argos
  VERSION = "1.1.2"
  
  def self.library_version
    "argos-ruby-#{VERSION}" 
  end
end
