module Argos

  # Argos DS|DAT file parser
  #
  # Usage
  #
  #   ds = Argos::Ds.new
  #   ds.log = Logger.new(STDERR)
  #   puts ds.parse(filename).to_json
  #
  #
  # For information about Argos, see: http://www.argos-system.org
  #
  # @author Espen Egeland
  # @author Conrad Helgeland
  # @todo errors => warn or remove unless asked for? (debug)
  class Ds < Array
    include Argos  

    attr_writer :log, :filename

    attr_reader :filename, :filter, :filtername, :valid, :filesize, :sha1, :messages

    START_REGEX = /^\d{5} \d{5,6} +\d+ +\d+/

    START_REGEX_LEGACY = /\s+\d\.\d{3}\s\d{9}\s+\w{4}$/

    LOCATION_CLASS = [nil, "0","1","2","3","A","B","G","Z"]

    def self.ds? filename
    end

    def filter?
      not @filter.nil?
    end
    
    def filter=filter
      if filter.respond_to? :call
        @filter = filter
      elsif filter =~ /lambda|Proc/
        @filtername = filter
        @filter = eval(filter)
      end
    end

    def log
      if @log.nil?
        @log = Logger.new(STDERR)
      end
      @log
    end

    # Parses Argos DS file and returns Argos::Ds -> Array
    #
    # The parser loops all messages (stored in @messages), before #unfold 
    # creates a sorted Array of measurements
    #
    #@param filename [String] Filename of Argos DS file
    #@return [Argos::Ds]
    def parse(filename=nil)

      self.clear # Needed if you parse multiple times
      @messages = []
      @valid = false

      if filename.nil?
        filename = @filename
      end
      

      filename = File.realpath(filename)
      @filename = filename
      if filename.nil? or not File.exists? filename
        raise ArgumentError, "Missing ARGOS DS file: \"#{filename}\""
      end
      @sha1 = Digest::SHA1.file(filename).hexdigest 

      contact = []
      file = File.open(filename)
      @filesize = file.size

      log.debug "Parsing ARGOS DS file #{filename} source:#{sha1} (#{filesize} bytes)"
      if filter?
        log.debug "Using filter: #{@filtername.nil? ? filter : @filtername }"
      end

      firstline = file.readline
      file.rewind

      if firstline =~ START_REGEX_LEGACY
        return parse_legacy(file)
      end

      file.each_with_index do |line, c|
        line = line.strip

        #if (c+1) % 1000 == 0
        #  log.debug "Line: #{c+1}"
        #end
        
        if line =~ START_REGEX

          @valid = true

          if contact.any?
            item = parse_message(contact)

            if self.class.valid_item? item  
              
              if not filter? or filter.call(item)
                @messages << item
              end
              
            else
              raise "Argos DS message #{filename}:#{c} lacks required program and/or platform"
            end
          end
  
          contact = [line]

        else 
          # 2010-12-14 15:11:34  1         00           37           01           52
          if contact.any? and line != ""
            contact << line
          end
        end
      end
  
      if false == @valid
        #log.debug file.read
        message = "Cannot parse file: #{filename}"
        raise ArgumentError, message 
      end

      last = parse_message(contact)

      # The last message
      if last
        if not filter? or filter.call(last)
          @messages << last
        end
      end
      
      log.debug "Parsed #{@messages.size} Argos DS messages into #{self.class.name} Array"  
      @segments = @messages.size
      unfold.each do |d|
        self << d
      end
      self
    end
  
    # Pare one DS segment
    def parse_message(contact)
      header = contact[0]
      body = contact[1,contact.count]
      items = process_item_body(body)
      combine_header_with_transmission(items, header)
    end
  
    def type
      "ds"
    end
  
    # @param [String] header
    # Header is is a space-separated string containing 
    #   [0] Program number
    #   [1] Platform number
    #   [2] Number of lines of data per satellite pass
    #   [3] Number of sensors
    #   [4] Satellite identifier
    #   [5] Location class (lc)
    #   [6] Location date 2007-03-02
    #   [7] Location UTC time
    #   [8] Latitude (decimal degrees)
    #   [9] Longitude, may be > 180 like 255.452°, equivalent to 255.452 - 360 = -104.548 (°E)
    #  [10] Altitude (km)
    #  [11] Frequency (calculated)
    #
    # The header varies in information elemenet, often either 0..4|5 or 0..11.
    # Header examples (plit on " "):
    #  ["09660", "10788", "4", "3", "D", "0"]
    #  ["09660", "10788", "5", "3", "H", "2", "1992-04-06", "22:12:16", "78.248", "15.505", "0.000", "401649604"]
    #  ["09660", "10788", "2", "3", "D"]
    # http://www.argos-system.org/files/pmedia/public/r363_9_argos_users_manual-v1.5.pdf page 42
    # 
    # Warning, the parser does not support this header format from 1989 [AUO89.DAT]
    # 19890800-19891000: ["09660", "14653", "10", "41", "14", "1", "-.42155E+1", "00", "112", "17DD"]
    def combine_header_with_transmission(measurements, header)
      unless header.is_a? Array
        header = header.split(" ")
      end
      latitude = longitude = positioned = nil
      warn = []
      errors = []

      lc = header[5]

      if not header[6].nil? and not header[7].nil?
        positioned = convert_datetime(header[6]+" "+header[7])
      end

      if header[8] != nil && valid_float?(header[8])
        latitude = header[8].to_f
      end
  
      if header[9] != nil && valid_float?(header[9])
        longitude = header[9].to_f
        if (180..360).include? longitude
          longitude = (longitude - 360)
        end
      end

      altitude = header[10]
      if not altitude.nil?
         altitude = altitude.to_f*1000
      end
        
      if positioned.nil? and measurements.nil?
        warn << "missing-time"
      end
        
      if latitude.nil? or longitude.nil?
        warn << "missing-position"
      else
      
        unless latitude.between?(-90, 90) and longitude.between?(-180, 180)
          errors << "invalid-position"
        end
      end

      unless LOCATION_CLASS.include? lc
        errors << "invalid-lc"
      end

      # Satellites 
      #  ["A", "B", "K", "L", "M", "N", "P", "R"] 

      document = { program:  header[0].to_i,
        platform: header[1].to_i,
        lines: header[2].to_i,
        sensors: header[3].to_i,
        satellite: header[4],
        lc: lc,
        positioned: positioned,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,        
        measurements: measurements,
        headers: header.size
      }
      if warn.any?
        document[:warn]=warn
      end
      if errors.any?
        document[:errors]=errors
      end
      
      document
    end
  
    # Merge position and all other top-level DS fields with each measurement line
    # (containing sensor data)
    # The 3 lines below will unfold to *2* documents, each with
    # "positioned":2010-03-05T14:19:06Z, "platform": "23695", "latitude":"79.989", etc.
    # 23695 074772   3  4 M B 2010-03-05 14:19:06  79.989   12.644  0.036 401639707
    #       2010-03-05 14:17:35  1         01           25        37630           36
    #       2010-03-05 14:20:38  1         00           28           00           65
    def unfold

      # First, grab all segments *without* measurements (if any)
      unfolded = messages.reject {|ds| ds.key?(:measurements) or ds[:measurements].nil? }
      log.debug "#{messages.size - unfolded.size} / #{messages.size} messages contained measurements"

      messages.select {|ds|
        ds.key?(:measurements) and not ds[:measurements].nil?
      }.each do |ds|
        
        ds[:measurements].each do |measurement|
          unfolded << merge(ds,measurement)
        end
      end
 
      unfolded = unfolded.sort_by {|ds|
        if not ds[:measured].nil?
          DateTime.parse(ds[:measured]) 
        elsif not ds[:positioned].nil?
          DateTime.parse(ds[:positioned])
        else
          ds[:program]
        end
      }

      log.info "Unfolded #{messages.size} ARGOS DS position and sensor messages into #{unfolded.size} new documents source:#{sha1} #{filename}"

      unfolded
    end

    def merge(ds, measurement)
      m = ds.select {|k,v| k != :measurements and k != :errors and k != :warn }     
      m = m.merge(measurement)          
      m = m.merge({ technology: "argos",
        type: type, filename: filename, source: sha1
      })

      if not ds[:errors].nil? and ds[:errors].any?
        m[:errors] = ds[:errors].clone
      end

      if not ds[:warn].nil? and ds[:warn].any?
        m[:warn] = ds[:warn].clone
      end

      if not m[:sensor_data].nil? and m[:sensor_data].size != ds[:sensors]
        if m[:warn].nil?
          m[:warn] = []
        end
        m[:warn] << "sensors-count-mismatch"
      end

      idbase = m.clone
      idbase.delete :errors
      idbase.delete :filename
      idbase.delete :warn
      
      id = Digest::SHA1.hexdigest(idbase.to_json)

      m[:parser] = Argos.library_version
      m[:id] = id
      m
    end

    def process_item_body(body_arr)
      @buf =""
      @transmission_arr = []
      @transmission_arr = recursive_transmission_parse(body_arr)
    end
  
  
    # @param [Array] body_arr
    # @return  [Aray]
    def recursive_transmission_parse(body_arr)
      if  body_arr.nil? or body_arr.empty?
        return
      end
      @buf =@buf + " " + body_arr[0]
  
      if body_arr[1] =~ /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/ or body_arr[1]==nil
        @transmission_arr << transmission_package(@buf)
        @buf=""
      end
      recursive_transmission_parse(body_arr[1,body_arr.length])
      @transmission_arr
    end
  
    def transmission_package(data)
      transmission_time = data[/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/,1]
      transmission_time = convert_datetime(transmission_time)

      identical = data.split(" ")[2].to_i    
      data = data.strip[23,data.length]

      if not data.nil?
        sensor_data = data.split(" ")
      end
      { measured: transmission_time,
        identical: identical,
        sensor_data: sensor_data
      }
    end

    def start
      positioned.map {|ds| ds [:positioned] }.first
    end

    def stop
      positioned.map {|ds| ds [:positioned] }.last
    end

    def source
      @sha1
    end
    
    protected

    # "1999-04-02 01:28:54"
    def convert_datetime(datetime)
    
    #AUO89.DAT/home/ch/github.com/argos-ruby/lib/ds.rb:143:in `parse': can't convert nil into String (TypeError)
    #/home/ch/github.com/api.npolar.no/seed/tracking/argos/19890800-19891000
    #AUO89.DAT/home/ch/github.com/argos-ruby/lib/ds.rb:149:in `parse': invalid date (ArgumentError)  
      begin  
        datetime = ::DateTime.parse(datetime).iso8601.to_s
        datetime['+00:00'] = "Z"
        datetime
      rescue
        log.error "Invalid date #{datetime}"
        DateTime.new(0).xmlschema.gsub(/\+00:00/, "Z")
      end
    end

    def positioned
      select {|ds|
        ds.key? :positioned and not ds[:positioned].nil?
      }
    end

    # Argos format until 1991
    # 
    #09660   6 09691  2 14286 89 042 17 18 05 1   3 G     0.000 401650000        0VDI
    #09660      2     59.891   10.629                           401649651        0VDJ
    #09660 14286 17 14 26  1  -.72543E+1           00                            0VDK
    #09660 14286 17 16 52  1  -.72410E+1           00                            0VDL
    #09660 14286 17 19 18  2  -.72376E+1           00                            0VDM
    #09660 14286 17 21 44  3  -.72376E+1           00                            0VDN
    
    # Header: 09660[program]   6[lines] ????? 2 ????? 89[year] 042[day?] 17 18 05[time?] 1   3[?] G[?]    0.000 \d{9}[f] \d\w{3}[ident]
    def parse_legacy(file)
      raise "Legacy DS file parser: not implemented"
      #file.each_with_index do |line, c|
      #  line = line.strip
      #  log.debug line
      #end
    end


    def valid_float?(str)
      !!Float(str) rescue false
    end

    def self.valid_item?(item)
      unless item.respond_to?(:key)
        return false
      end
      item.key?(:program) and item.key?(:platform)
    end

  end
end