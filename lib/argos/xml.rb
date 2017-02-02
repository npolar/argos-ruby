require "nokogiri"
require "uuidtools"

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

    #@todo validate decoder on set
    attr_accessor :log, :sensor_decoder

    def initialize(xml=nil, sensor_decoder=nil)
      @filename = nil
      if not xml.nil?
        self.xml=xml
      end
      if not sensor_decoder.nil? and sensor_decoder.is_a?(Argos::SensorData)

        self.sensor_decoder=sensor_decoder
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

    def to_a(xsltfile=File.join(__dir__, "_xslt", "argos-buoy-json.xslt"))
      xslt = Nokogiri::XSLT(File.read(xsltfile))
      json_string = xslt.apply_to(@document, ["filename", @filename, "npolar.no", "true"])

      a = JSON.parse(json_string)

      if sensor_decoder.nil? and a.length > 0
        models = a.map {|m| m["platform_model"]}.uniq
        if models.size == 1
          log.info "Setting decoder from platform_model #{models[0]}"
          set_decoder_from_platform_model(models[0])
        end
      end

      if sensor_decoder.is_a?(Argos::SensorData) or sensor_decoder.respond_to?(:data)
        a = decode(a)
      end

      #log.info "Before: #{a.size}"
      a = a.select {|m|
        log.info "#{m[:latitude]} #{m[:longitude]}"
        #  # (m[:measured_best] == m[:measured])
        (m.key?(:latitude) and m.key?(:longitude) and m[:latitude] < 90 and m[:longitude] < 180)
        true
      }
      log.debug "After: #{a.size}"
      a
    end

    def decode(a)
      a.map {|m|
        @sensor_decoder.sensor_data=m["argos"]["sensor_data"]

        sensor_decoder.data.each {|k,v|
          m[k]=v
        }
        m[:latitude_argos] = m["argos"]["latitude"]
        m[:longitude_argos] = m["argos"]["longitude"]
        m[:latitude_argos2] = m["argos"]["latitude2"]
        m[:longitude_argos2] = m["argos"]["longitude2"]

        m[:program] = m["argos"]["program"]
        m[:platform] = m["argos"]["platform"]
        m[:measured] = m["argos"]["measured"]
        m[:measured_best] = m["argos"]["measured_best"]
        m[:raw]= m["argos"]["sensor_hex"]

        m[:schema] = "http://api.npolar.no/schema/oceanography_point-1.0.1"
        m[:collection] = "buoy"
        m[:owner] = "NPI"
        m[:title] = "IC_2015a"
        m[:type] = "MetOcean ICEB-CAN16-103"

        m[:id] = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, "http://api.npolar.no/oceanography/buoy/#{m.to_json}")

        m.delete "argos"

        #m[:gps] = data
        #log.info data.to_json
        #log.info m.select {|k,v| k=~/^(latitude|longitude|measured)$/}.to_json
        #m.delete "sensor"
        #m.delete "sensor_data"
        #m.delete "collect"
        #m[:sensor_decoded] = data
        m
      }
    end

    def set_decoder_from_platform_model(m)

      if m =~ /MetOcean/i
        decoder = MetOceanFID2125Decoder.new
        decoder.sensor_data_format = "hex"
      elsif m =~ /KiwiSat/i
        decoder = KiwiSat303Decoder.new
        decoder.sensor_data_format = "hex"
      else
        log.warn "Unknown platform_model: #{m}"
      end

      log.info decoder.class.name
      @sensor_decoder=decoder
    end

  end
end