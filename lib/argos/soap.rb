root = File.dirname(File.realpath(__FILE__))+"/../.."

Dir.chdir root do
  begin
    require "savon"
  rescue LoadError
    # Prepend Savon lib to path, bundler seems not work
    unless defined? Savon
      # Cannot use #find_name returns []
      # raise Bundler.rubygems.find_name('savon').to_json #.first.full_gem_path
      savonbundle = `bundle show savon`.chomp
      $LOAD_PATH.unshift(savonbundle+"/lib")
      require_relative "#{savonbundle}/lib/savon"
    end
  end
end

module Argos
  class Soap

    # A [simple](http://wanderingbarque.com/nonintersecting/2006/11/15/the-s-stands-for-simple/) Soap client for the Argos satellite tracking webservice operated by CLS
    
    # client [Savon] (version 3)
    # request [String] Soap:Envelope (XML request body)
    # response [Savon::Response]
    # operation [Savon::Operation]
    # log [Logger]
    # xml [String] (Extracted, inner) XML
    # filter 
    # platformId [String] Comma-separated list of platforms
    # programNumber [String] Comma-separated list of programs
    # nbDaysFromNow
    # period
    attr_accessor :client, :request, :response, :operation, :log, :xml, :filter,
      :platformId, :programNumber, :nbDaysFromNow, :period
    # username [String]
    # password [String]
    attr_writer :username, :password
    
    URI = "http://ws-argos.cls.fr/argosDws/services/DixService"
    # Alternative: "http://ws-argos.clsamerica.com/argosDws/services/DixService"
    
    WSDL = "#{URI}?wsdl"       
    
    ARGOS_NS = "http://service.dataxmldistribution.argos.cls.fr/types"
    
    SOAP_NS = "http://www.w3.org/2003/05/soap-envelope"
    
    NAMESPACES = {
      "soap" => SOAP_NS,
      "argos" => ARGOS_NS
    }
    
    # Constructor
    # soap = Argos::Soap.new({username: "argos-system-user", password: "argos-system-pw"})
    def initialize(config={})
      config.each do |k,v|
        case k.to_sym
        when :username
          @username=v
        when :password
          @password=v
        when :wsdl
          @wsdl=v
        when :programNumber
          @programNumber = v
        when :platformId
          @platformId = v
        when :nbDaysFromNow
          @nbDaysFromNow = v.to_i
        when :period
          @period = v
        when :filter
          @filter = v
        else
          #raise ArgumentError, "Unkown config key: #{k}"
        end
      end
    end
    
    # Build baseRequest Hash
    # The service requires programNumber or PlatformId, but if you do not provide any,
    # this method will call the service (@see #programs) and get the current user's programs
    # @return [Hash]
    def baseRequest
      # if override key is platformId... delete programNumber...
      # if override key is period... delete nbDaysFromNow...
      baseRequest = { username: _username, password: _password }
      
      # First choice (program or platform)
      if @programNumber.nil? and @platformId.nil?
        # Fetch all programs if neither is provided
        baseRequest[:programNumber] = programs.map {|p|p.to_s}.join(",")
      elsif @programNumber.to_s =~ /\d+/ and @platformId.to_s =~ /\d+/
        baseRequest[:platformId] = @platformId # ignores programNumber
      elsif @programNumber.to_s =~ /\d+/ 
        baseRequest[:programNumber] = @programNumber
      elsif @platformId.to_s =~ /\d+/
        baseRequest[:platformId] = @platformId
      end
      
      # 2nd choice (time)
      if @nbDaysFromNow.nil? and @period.nil?
        # Default to 20 days of data (the maximum)
        baseRequest[:nbDaysFromNow] = 20
      elsif @nbDaysFromNow =~ /\d+/ and not @period.nil?
        raise "Cannot provide both nbDaysFromNow and period"
      elsif @nbDaysFromNow.to_s =~ /\d+/ 
        baseRequest[:nbDaysFromNow] = @nbDaysFromNow.to_i
      else
        baseRequest[:period] = @period
      end
      
      #baseRequest = baseRequest.merge({
        # @todo 
        #<xs:element minOccurs="0" name="referenceDate" type="tns:referenceDateType"/>
        #<xs:element minOccurs="0" name="locClass" type="xs:string"/>
        #<xs:element minOccurs="0" name="geographicArea" type="xs:string"/>
        #<xs:element minOccurs="0" name="compression" type="xs:int"/>
        #<xs:element minOccurs="0" name="mostRecentPassages" type="xs:boolean"/>
      #})
      baseRequest
      
    end
        
    # @return [Savon]
    def client
      @client ||= begin  
        
        tmpwsdl = "/tmp/argos-soap.wsdl"        
        if File.exists?(tmpwsdl)
          uri = tmpwsdl
        else
          uri = @wsdl||=WSDL
        end
        
        client = ::Savon.new(uri)
        if not File.exists?(tmpwsdl)
          response = ::Net::HTTP.get_response(::URI.parse(WSDL))
          File.open(tmpwsdl, "wb") { |file| file.write(response.body)}
        end
        client
      end
    end
    
    def filter?
      not @filter.nil? and filter.respond_to?(:call)
    end

    # @return [String]
    def getCsv
      o = _operation(:getCsv)
      o.body = { csvRequest: baseRequest.merge(
        showHeader: true).merge(xmlRequest)
      }
      @response = o.call
      @request = o.build
      
      # Handle faults (before extracting data)
      _envelope.xpath("soap:Body/soap:Fault", namespaces).each do | fault |
        raise fault.to_s
      end
      
      @text = _extract_escaped_xml("csvResponse").call(response)
    end
    
    # @return [Hash]
    def getKml
      _call_xml_operation(:getKml, { kmlRequest: baseRequest.merge(xmlRequest)}, _extract_escaped_xml("kmlResponse"))
    end
    
    # @return [Hash]
    # {"data":{"program":[{"programNumber":"9660","platform":[{ .. },{ .. }]}],"@version":"1.0"}}
    # Each platform Hash (.. above): {"platformId":"129990","lastLocationClass":"3","lastCollectDate":"2013-10-03T08:32:24.000Z","lastLocationDate":"2013-05-22T04:55:15.000Z","lastLatitude":"47.67801","lastLongitude":"-122.13419"}
    def getPlatformList
      platformList = _call_xml_operation(:getPlatformList, { platformListRequest:
        # Cannot use #baseRequest here because that methods calls #programs which also calls #getPlatformList...
        { username: _username, password: _password },
      }, _extract_escaped_xml("platformListResponse"))
      
      # Raise error if no programs
      if platformList["data"]["program"].nil?
        raise platformList.to_json
      end
      # Force Array
      if not platformList["data"]["program"].is_a? Array
        platformList["data"]["program"] = [platformList["data"]["program"]]
      end
      platformList
    end
    
    # @return [Hash]
    def getXml
      _call_xml_operation(:getXml,
        { xmlRequest: baseRequest.merge(xmlRequest)},
        _extract_escaped_xml("xmlResponse"))
    end
    
    # @return [Hash]
    def getStreamXml
      _call_xml_operation(:getStreamXml,
        { streamXmlRequest: baseRequest.merge(xmlRequest)},
        _extract_motm)
    end 
    
    # @return [Hash]
    def getXsd  
      _call_xml_operation(:getXsd, { xsdRequest: {} }, _extract_escaped_xml("xsdResponse"))
    end
    
    # @return [Hash]
    # choice: programNumber | platformId | wmo*
    # nbMaxObs
    def getObsXml
      _call_xml_operation(:getObsXml,
        { observationRequest: baseRequest.merge(xmlRequest)},
        _extract_escaped_xml("observationResponse"))
    end
    
    # @return [Text]
    # choice: programNumber | platformId | wmo*
    # nbMaxObs
    def getObsCsv
      o = _operation(:getObsCsv)
      o.body = { observationRequest: baseRequest.merge(xmlRequest)
      }
      @response = o.call
      @request = o.build
      @text = _extract_escaped_xml("observationResponse").call(response)
    end
    
    # Platforms: array of platformId integers
    # @return [Array] of [Integer]
    def platforms
      platforms = []

      platformListPrograms = getPlatformList["data"]["program"]

      if @programNumber.to_s =~ /\d+/
        platformListPrograms.select! {|p| p["programNumber"].to_i == @programNumber.to_i }
      end
      
      platformListPrograms.each do |program|
        platforms  += program["platform"].map {|p| p["platformId"].to_i}
      end
      platforms
    end
    
    # Period request
    def period(startDate, endDate)  
      { startDate: startDate, endDate: endDate }
    end
    
    # Programs: Array of programNumber integers
    # @return [Array]
    def programs
      platformList = getPlatformList
      if platformList.key?("data") and platformList["data"].key?("program")
        platformList["data"]["program"].map {|p| p["programNumber"].to_i }
      else
        raise platformList
      end
    end

    # @return [String]
    def raw
      response.raw
    end
    
    # @return [String]
    def request
      if operation.nil?
        nil
      else
        operation.build
      end
    end
    
    # @return [Hash] {"DixService":{"ports":{"DixServicePort":{"type":"http://schemas.xmlsoap.org/wsdl/soap12/","location":"http://ws-argos.cls.fr/argosDws/services/DixService"}}}}
    def services
      client.services
    end
    
    # @return [String]
    def text
      @text||=""
    end

    # @return [Array] [:getCsv, :getStreamXml, :getKml, :getXml, :getXsd, :getPlatformList, :getObsCsv, :getObsXml] 
    def operations
      @response = client.operations(:DixService, :DixServicePort)
    end
    
    def namespaces
      NAMESPACES
    end
    
    def xmlRequest
      {
        displayLocation: true,
        displayDiagnostic: true,
        displayMessage: true,
        displayCollect: true,
        displayRawData: true,
        displaySensor: true,
        #argDistrib: "",
        displayImageLocation: true,
        displayHexId: true  
      }
    end
    
    protected
    
    # Build and call @operation, set @response, @request, and @xml
    # @raise on faults
    # @return [Hash]
    def _call_xml_operation(op_sym, body, extract=nil)
      @operation = _operation(op_sym)
      @operation.body = body
      @response = operation.call

      # Check for http errors?

      # Handle faults (before extracting data)
      _envelope.xpath("soap:Body/soap:Fault", namespaces).each do | fault |
        raise Exception, fault.to_s
      end
      
      # Extract data
      if extract.respond_to?(:call)
        @xml = extract.call(response)
      else
        @xml = response.raw
      end
      
      # Handle errors
      ng = Nokogiri.XML(xml)
      ng.xpath("/data/errors/error").each do | error |
        if error.key?("code")
          case error["code"].to_i
          when 4
            raise NodataException
          end
          #<error code="2">max response reached</error>
          #<error code="3">authentification error</error>
          #<error code="9">start date upper than end date</error>
        else
          raise Exception, error
        end
      end
      
      # Validation - only for :getXml?
      if [:getXml].include? op_sym
        # Validation against XSD does not work: ["Element 'data': No matching global declaration available for the validation root."]
        schema = Nokogiri::XML::Schema(File.read("#{__dir__}/_xsd/argos-data.xsd"))
        v = schema.validate(ng)
        if v.any?
          log.debug "#{v.size} errors: #{v.map{|v|v.to_s}.uniq.to_json}"
        end
      end
      

      # Convert XML to Hash
      nori = Nori.new
      nori.parse(xml)
    end
    
    # This is a shame, but who's to blame when there's multiple XML prologs (the second is escaped) and even mix of (declared) encodings (UTF-8 in soap envelope, ISO-8859-1 inside)
    # Note: the inner data elements are non-namespaced (see da), so that recreating as proper XML would need to set xmlns=""
    def _extract_escaped_xml(responseElement)
      lambda {|response| CGI.unescapeHTML(response.raw.split("<#{responseElement} xmlns=\"http://service.dataxmldistribution.argos.cls.fr/types\"><return>")[1].split("</return>")[0])}
    end
    
    # This is proof-of-concept quality code.
    # @todo Need to extract boundary and start markers from Content-Type header:
    # Content-Type: multipart/related; type="application/xop+xml"; boundary="uuid:14b8db9f-a393-4786-be3f-f0f7b12e14a2"; start="<root.message@cxf.apache.org>"; start-info="application/soap+xml"

    # @return [String]
    
    def _extract_motm
      lambda {|response|
        # Scan for MOTM signature --uuid:*
        if response.raw =~ (/^(--[\w:-]+)--$/)
          # Get the last message, which is -2 because of the trailing --
          xml = response.raw.split($1)[-2].strip

          # Get rid of HTTP headers
          if xml =~ /\r\n\r\n[<]/
            xml = xml.split(/\r\n\r\n/)[-1]
          end
          
        else
          raise "Cannot parse MOTM"
        end
        }
    end
    
    # @return [Nokogiri:*]
    def _envelope
      ng = Nokogiri.XML(response.raw).xpath("/soap:Envelope", namespaces)
      if not ng.any?
        # Again, this is a shame...
        envstr = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">'
        extracted = envstr + response.raw.split(envstr)[1].split("</soap:Envelope>")[0] + "</soap:Envelope>"
        ng = Nokogiri.XML(extracted).xpath("/soap:Envelope", namespaces)
      end
      ng
    end
        
    # @return [Savon::Operation]
    def _operation(operation_name)
      client.operation(:DixService, :DixServicePort, operation_name)
    end
    
    # @return [String]
    def _username
      @username||=ENV["ARGOS_SOAP_USERNAME"]
    end
    
    # @return [String]
    def _password
      @password||=ENV["ARGOS_SOAP_PASSWORD"]
    end
    
  end  
end