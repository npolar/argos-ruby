require "fileutils"
require "logger"
require "time"

module Argos
  
  # Download utility class to take the strain out of downloading and
  # archiving Argos XML and CSV for multiple users, programs and platforms.
  #
  # Downlods the last 20 days, one day at a time, and stores data in the following structure
  # /{archive}/{year}/program-{programNumber}/platform-{platformId}/argos-{YYYY-MM-DD}-platform-{platformId}.[xml|csv]
  #
  # Command line:
  # $ ./bin/argos-soap --download /mnt/tracking/ws-argos.cls.fr --username=xyz --password=123

  class Download
    
    def self.download(username, password, archive, log, days=20)
      
      soap = Argos::Soap.new({username: username, password: password})
      soap.log = log
      
      programs = soap.programs
      
      year = DateTime.now.year
  
      soap.getPlatformList["data"]["program"].each do |program|
        programNumber = program["programNumber"]
        soap.programNumber = programNumber
      
        platforms = soap.platforms
        log.debug "Program: #{program["programNumber"]}, #{platforms.size} platform(s)"
        
        program["platform"].select {|platform|
          
          lastCollectDate = DateTime.parse(platform["lastCollectDate"])
          lastLocationDate = DateTime.parse(platform["lastLocationDate"])
          
          twentydays = DateTime.parse((Date.today-20).to_s)
          
          (lastCollectDate > twentydays or lastLocationDate > twentydays)
          
          }.each_with_index do | platform, idx |
          
      
          platformId = platform["platformId"]
          soap.platformId = platformId
          
          log.debug "Program: #{programNumber}, platform: #{platformId}, lastCollectDate: #{platform["lastCollectDate"]}"
        
          20.downto(1) do |daysago|
            
            date = Date.today-daysago
            
            destination = "#{archive}/#{year}/program-#{programNumber}/platform-#{platformId}"
          
            begin
              soap.period = {startDate: "#{date}T00:00:00Z", endDate: "#{date}T23:59:59.999Z"}
              soap.getXml
              
              
              FileUtils.mkdir_p(destination)
              filename = destination+"/argos-#{date}-platform-#{platformId}.xml"
                
              File.open(filename, "wb") { |file| file.write(soap.xml)}
              log.debug "Saved #{filename}"
              
              soap.getCsv
              
              File.open(filename.gsub(/xml$/, "csv"), "wb") { |file| file.write(soap.text)}
                
            rescue Argos::NodataException
              # noop
            rescue => e
              log.error e
            end
            
          end
        end
      end
    end
    
  end
end