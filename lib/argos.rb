require "bundler/setup"
require "bigdecimal"
require "date"
require "time" # for #iso8601
require "digest/sha1"
require "json"
require "logger"
require "cgi"
require "savon"

require_relative "argos/exception"
require_relative "argos/ascii"
require_relative "argos/ds"
require_relative "argos/diag"
require_relative "argos/soap"
require_relative "argos/download"
require_relative "argos/sensor"
require_relative "argos/kiwisat303"

# [Argos](http://www.argos-system.org) satellite tracking data tools
# * Parsers for Argos legacy ASCII files (DS/DAT and DIAG/DIA files)
# * SOAP web service client and Argos XML download tool
#
# https://github.com/npolar/argos-ruby
#
# Code written by staff at the [Norwegian Polar Data Centre](http://data.npolar.no),
# [Norwegian Polar Institute](http://npolar.no)
# 
# For information about Argos, see: http://www.argos-system.org
module Argos
  def self.library_version
    "argos-ruby-#{VERSION}" 
  end
end
