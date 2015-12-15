require "nokogiri"

module Argos

  # Argos XML file parser
  #
  # Usage
  #
  #   argos_xml = Argos::Xml.new
  #   puts argos_xml.parse(filename).to_json
  #
  # @author Conrad Helgeland
  # 
  class Xml
    
    attr_accessor :log
    
    def initialize(xml=nil)
      @filename = nil
      if not xml.nil?
        self.xml=xml
      end
      
      @log = Logger.new(STDERR)
    end
    
    def xml=xml
      if File.exists? xml
        @filename = xml
        xml = File.read(xml)
      end 
      @document = Nokogiri::XML(xml)
    end
    
    def to_a
      xslt = Nokogiri::XSLT(File.read(File.join(__dir__, "_xslt", "argos-json.xslt")))
      json_string = xslt.apply_to(@document, ["filename", @filename, "npolar.no", "true"])
      JSON.parse(json_string)
    end
    
  end
end