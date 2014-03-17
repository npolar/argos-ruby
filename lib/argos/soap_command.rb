require "optparse"  
require "net/http"
require "csv"

module Argos
  
  # argos-soap command
  #
  # On success, data is pumped to STDOUT, on faults/errors to STDERR
  # Examples:
  # $ argos-soap --operation getXml
  # $ argos-soap -o getXml --startDate="2014-03-10T00:00:00Z" --endDate="2014-03-10T23:59:59.999Z" --log-level=1
  # $ argos-soap -o getXml --startDate="`date --date=yesterday -I`T00:00:00Z" --endDate="`date --date=yesterday -I`T23:59:59.999Z" --username=**** --password=***** > /my/argos/xml/archive/`date -I --date=yesterday`.xml
  class SoapCommand
     
    CMD = "argos-soap"
    
    PARAM = { format: :json, wsdl: Argos::Soap::WSDL }
    
    def self.run(argv=ARGV)
      begin
        cmd = new(argv)
        cmd.run
        exit(true)
      rescue => e
        STDERR.write e
        STDERR.write e.backtrace.join("\n")
        exit(false)
      end
    end
    
    attr_accessor :log, :param, :result, :soap
  
    def initialize(argv=ARGV, param = PARAM)
      @param = param

      option_parser = OptionParser.new(argv) do |opts|
      
        opts.version = Argos::VERSION
      
        opts.banner = "#{CMD} operation [options]\n"

        opts.on("--debug", "Debug (alias for --log-level=0") do
          @param[:level] = Logger::DEBUG
        end
        
        # --date shorthand for 1 day startDate endDate

        opts.on("--format=format", "-f=format", "{ json | xml | text | raw }") do |format|
          @param[:format] = format.to_sym
        end
        
        opts.on("--operation=operation", "-o=operation", "{ #{operations.join(" | ")} }") do |operation|
          @param[:operation] = operation.to_sym
          # Change format (from JSON) for XML and text-operations
          if [:getKml, :getObsXml, :getStreamXml, :getXml, :getXsd].include? param[:operation]
            @param[:format] = :xml
          elsif [:getCsv].include? param[:operation]
            @param[:format] = :text
          end          
        end
        
        opts.on("--log-level=level", "Log level") do |level|
          @param[:level] = level.to_i
        end
        
        opts.on("--nbDaysFromNow=days", "Set number of days") do |nbDaysFromNow|
          @param[:nbDaysFromNow] = nbDaysFromNow
        end
        
        opts.on("--startDate=dateTime", "Set period start") do |startDate|
          @param[:period] = { startDate: startDate}
        end
        
        opts.on("--endDate=dateTime", "Set period end") do |endDate|
          @param[:period] = (@param[:period]||{}).merge({ endDate: endDate })
        end
        
        opts.on("--operations", "List operations") do
          @param[:operation] = :operations
        end
                
        opts.on("--platforms", "List platforms") do
          @param[:operation] = :platforms
        end
        
        opts.on("--programs", "List programs") do
          @param[:operation] = :programs
        end
        
        opts.on("--programNumber=program1,program2", "Set programNumber(s)") do |programNumber|
          @param[:programNumber] = programNumber
        end
        
        opts.on("--platformId=platform1,platform2", "Set platformId(s)") do |platformId|
          @param[:platformId] = platformId
        end

        opts.on("--services", "Services (from WSDL)") do
          @param[:operation] = :services
        end

        opts.on("--username=username", "Set username") do |username|
          if not username.nil?
            @param[:username] = username
          end
        end
        
        opts.on("--password=password", "Set passord") do |password|
          if not password.nil?
            @param[:password] = password
          end
        end

      end
      option_parser.parse!
      
      if operation.nil?
        STDOUT.write option_parser.help
        exit(false)
      end
      
      @log = Logger.new(STDERR)
      @log.level = param[:level].to_i
    end
    
    def debug?
      @param[:level] == Logger::DEBUG
    end
    
    def run
      begin
        @soap = Argos::Soap.new(param)
        
        @result = nil
        
        case param[:operation]
        when :getCsv
          @result = soap.getCsv 
        when :getPlatformList
          @result = soap.getPlatformList
        when :getKml
          @result = soap.getKml
        when :getObsCsv
          @result = soap.getObsCsv
        when :getObsXml
          @result = soap.getObsXml
        when :getStreamXml
          @result = soap.getStreamXml
        when :getXml
          @result = soap.getXml
        when :getXsd
          @result = soap.getXsd
        when :operations
          @result = soap.operations
        when :platforms
          @result = soap.platforms(param[:programNumber])
        when :programs
          @result = soap.programs
        when :services
          @result = soap.services
        else
          raise ArgumentError, "Unspported operation: #{param[:operation]}"  
        end
        STDOUT.write output
        
      rescue NodataException
        log.debug output
      rescue => e
        STDERR.write output
      end

    end
    
    protected
    
    def output
      
      if debug?
        log.debug "#{CMD} param: #{param.to_json}"
        log.debug "$ curl -XPOST #{Argos::Soap::URI} -d'#{soap.request}' -H \"Content-Type: application/soap+xml\""
      end
      
      if result.is_a? Savon::Response
        @result = result.raw
      end
      
      output = case format.to_sym
      
      when :ruby
        result
      when :json
        result.to_json
      when :text
        soap.text
      when :raw
        soap.raw
      when :xml
        # Return XML with parameter and time in trailing comment
        soap.xml+"<!-- #{param.reject {|k,v| k =~ /^password$/}.to_json} now: #{Time.now.utc.xmlschema} -->"
      else
        raise ArgumentError, "Unknown format: #{format}"
      end
      
    end
    
    def format
      param[:format]
    end
    
    def operation
      param[:operation]
    end
    
    def operations
      [:getCsv, :getStreamXml, :getKml, :getXml, :getXsd, :getPlatformList, :getObsCsv, :getObsXml] 
    end
    
  end
end