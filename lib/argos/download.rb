require "fileutils"
require "logger"
require "time"
require "digest"
require "nokogiri"

module Argos
  
  # Download utility class to take the strain out of downloading and
  # archiving Argos XML and CSV for multiple users, programs and platforms.
  #
  # Downlods the last 20 days, one day at a time, and stores data in the following structure
  # /{archive}/{year}/program-{programNumber}/platform-{platformId}/argos-{YYYY-MM-DD}-platform-{platformId}.[xml|csv]
  #
  # Command line:
  # $ ./bin/argos-soap --download /tmp/tracking/ws-argos.cls.fr --username=xyz --password=123 --debug
  # Crontab example:
  # 27 3 * * * source /home/argos/.rvm/environments/default && argos-soap --download /var/ws-argos.cls.fr --username=user --password=pw


  class Download
    
    def self.download(username, password, archive, log, days=20)
      
      log.debug "Starting download of Argos XML to #{archive}"
      
      soap = Argos::Soap.new({username: username, password: password})
      soap.log = log
      
      programs = soap.programs
      log.debug "Programs for #{username}: #{programs.to_json}"
      year = DateTime.now.year
  
      soap.getPlatformList["data"]["program"].each do |program|
        programNumber = program["programNumber"]
        soap.programNumber = programNumber
      
        platforms = soap.platforms
        
        # inactive (no last collect)
        inactive = program["platform"]
        
        active = program["platform"].select {|platform|
          platform.key? "lastCollectDate" and platform.key? "lastLocationDate"}.select {|platform|
          
          lastCollectDate = DateTime.parse(platform["lastCollectDate"])
          lastLocationDate = DateTime.parse(platform["lastLocationDate"])
          
          twentydays = DateTime.parse((Date.today-20).to_s)
          
          (lastCollectDate > twentydays or lastLocationDate > twentydays)
          
        }
        # inactive = platforms where last collect date is missing or > 20 days
        inactive = program["platform"] - active

        active.each_with_index do |a,m|
          log.debug "Active [#{m+1}/#{active.size}]: #{a.reject{|k,v| k =~ /location/i }.to_json}"
        end
        inactive.each_with_index do |i,n|
          log.debug "Inactive [#{n+1}/#{inactive.size}]: #{i.reject{|k,v| k =~ /location/i }.to_json}"
        end
        active.each_with_index do | platform, idx |
          
      
          platformId = platform["platformId"]
          soap.platformId = platformId
          
          log.debug "About to download program: #{programNumber}, platform: #{platformId} [#{idx+1}/#{active.size}], lastCollectDate: #{platform["lastCollectDate"]}"
        
          20.downto(1) do |daysago|
            
            date = Date.today-daysago
            
            destination = "#{archive}/#{year}/program-#{programNumber}/platform-#{platformId}"
          
            begin
              soap.period = {startDate: "#{date}T00:00:00Z", endDate: "#{date}T23:59:59.999Z"}
              soap.getXml
              
              FileUtils.mkdir_p(destination)
              filename = destination+"/argos-#{date}-platform-#{platformId}.xml"
              
              if File.exists? filename
                existing_sha1 = Digest::SHA1.file(filename).hexdigest
                existing_errors = Argos::Soap.new.validate(File.read(filename))
                if existing_errors.any?
                  log.error "Validation error for existing data #{filename} (#{File.size(filename)} bytes): #{existing_errors.uniq.to_json}"
                end 
                #log.debug "Keeping existing file #{filename} from #{File.mtime(filename)}, fresh data is identical"
              end
              
              new_xml_ng = Nokogiri::XML(soap.xml, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::NOCDATA | Nokogiri::XML::ParseOptions::STRICT)
              new_xml = new_xml_ng.canonicalize
              new_sha1 = Digest::SHA1.hexdigest(new_xml)
              
              if existing_sha1.nil? or existing_errors.any? or existing_sha1 != new_sha1
              
                if errors = Argos::Soap.new.validate(new_xml_ng).any?
                  raise "Failed XML schema validation"
                else
                  File.open(filename, "wb") { |file| file.write(new_xml)}
                  log.debug "Validated and saved new data: #{filename}"
                end
                
              end
              log.debug "Day -#{daysago}: #{date}: #{new_xml_ng.xpath("//message").size} message(s) (program #{programNumber}, platform #{platformId})"
            rescue Argos::NodataException
              # noop
              log.debug "Day -#{daysago}: #{date}: No data for (program #{programNumber}, platform #{platformId})"
            rescue => e
              log.error e
            end
            
          end
          
          log.debug "Completed download of #{platformId}"
          
        end
        log.debug "Completed download for #{username}"
      end
    end
    
  end
end
