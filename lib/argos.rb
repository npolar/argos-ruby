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
# http://data.npolar.no - a unit of [Norwegian Polar Institute](http://npolar.no)
# 
# For information about Argos, see: http://www.argos-system.org
module Argos

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
      when Argos::Ds::START_REGEX
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

  # Source fingerprint of Argos file (sha1 hash, segment and document counts, etc.)
  #
  # @param  [Argos::Ds Argos::Diag] argos
  # @return [Hash]
  def self.source(argos)

    argos.parse(argos.filename)

    { id: argos.source,
      type: argos.type,
      programs: argos.programs,
      platforms: argos.platforms,
      start: argos.start,
      stop: argos.stop,
      filename: argos.filename,
      filesize: argos.filesize,
      messages: argos.messages.size,
      filter: argos.filtername.nil? ? argos.filter : argos.filtername,
      size: argos.size,
    }
  end

end