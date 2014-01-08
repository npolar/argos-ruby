require "bigdecimal"
require "date"
require "digest/sha1"
require "json"
require "logger"

require_relative "argos/exception"
require_relative "argos/ds"
require_relative "argos/diag"

# Argos module
# Contains parsers for Argos DS/DAT and DIAG files.
# 
# Code written by staff at the Norwegian Polar Data Centre
# http://data.npolar.no - a service run by the [Norwegian Polar Institute](http://npolar.no)
# 
# For information about Argos, see: http://www.argos-system.org
module Argos
  VERSION = "1.0.2"
  # Detect Argos type ("ds" or "diag" or nil)
  #
  # @param filename [String] Argos (DS or DIAG) file
  # @return [String]
  #"ds"|"diag"
  def self.type filename

    if File.file? filename
      # Avoid invalid byte sequence in UTF-8 (ArgumentError)
      firstline = File.open(filename, :encoding => "iso-8859-1") {|f| f.readline}
    else
      firstline = filename
    end

    case firstline
      when Argos::Ds::START_REGEX, Argos::Ds::START_REGEX_LEGACY
        "ds"
      when Argos::Diag::START_REGEX
        "diag"
      when "", nil
        raise ArgumentError, "Not a file or empty string: #{filename}"
      else nil
    end 
  end

  # Argos file?
  #
  # @param filename [String] Argos (DS or DIAG) file
  # @return [Boolean]
  def self.argos?(filename)
    case type(filename)
    when "ds", "diag"
      true
    else
      false
    end
  end

  # Factory for Argos::Ds / Argos::Diag
  #
  # @param type [String]: Argos (DS or DIAG) file type (or filename)
  # @return [Argos::Ds Argos::Diag]
  # @throws ArgumentError
  def self.factory(type)

    # Auto-detect file format if not "ds" or "diag"
    if not ["ds","diag"].include? type
      if argos? type
        type = self.type(type)
      end
    end

    case type
    when "ds"
      Ds.new
    when "diag"
      Diag.new
    else
      raise ArgumentError, "Unknown Argos type: #{type}"
    end
  end


  def self.library_version
    "argos-ruby-#{VERSION}" 
  end

  # Source fingerprint of Argos file (sha1 hash, segment and document counts, etc.)
  #
  # @param  [Argos::Ds Argos::Diag] argos
  # @return [Hash]
  def self.source(argos)

    argos.parse(argos.filename)

    latitude_mean = longitude_mean = nil
    if argos.latitudes.any?
      latitude_mean = (argos.latitudes.inject{ |sum, latitude| sum + latitude } / argos.latitudes.size).round(3)
    end
    if argos.longitudes.any?
      longitude_mean = (argos.longitudes.inject{ |sum, longitude| sum + longitude } / argos.latitudes.size).round(3)
    end
    

    source = {
      id: argos.source,
      technology: "argos",
      collection: "tracking",
      type: argos.type,
      programs: argos.programs,
      platforms: argos.platforms,
      start: argos.start,
      stop: argos.stop,
      north: argos.latitudes.max,
      east: argos.longitudes.max,
      south: argos.latitudes.min,
      west: argos.longitudes.min,
      latitude_mean: latitude_mean,
      longitude_mean: longitude_mean,
      location: "file://"+argos.filename,
      bytes: argos.filesize,
      updated: argos.updated.xmlschema,
      messages: argos.messages.size,
      filter: argos.filtername.nil? ? argos.filter : argos.filtername,
      size: argos.size,
      parser: library_version
    }
    if argos.multiplicates.any?
      source[:multiplicates] = argos.multiplicates.map {|a| a[:id]}
    end
    if argos.errors.any?
      source[:errors] = argos.errors
    end
    source
    
  end


  def latitudes
    select {|a| a.key? :latitude and a[:latitude].is_a? Float }.map {|a| a[:latitude]}.sort
  end

  def longitudes
    select {|a| a.key? :longitude and a[:longitude].is_a? Float }.map {|a| a[:longitude]}.sort
  end

  def platforms
    map {|a| a[:platform]}.uniq.sort
  end

  def programs
    map {|a| a[:program]}.uniq.sort
  end
  
end
