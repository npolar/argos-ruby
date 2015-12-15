module Argos

  # Argos DIAG file parser
  #
  # Usage
  #
  #   diag = Argos::Diag.new
  #   puts diag.parse(filename).to_json
  #
  # @author Espen Egeland
  # @author Conrad Helgeland
  class Diag < Array
    include Argos::Ascii
  
    LOCATION_CLASS = ["3", "2", "1", "0", "A", "B", "Z"]

    attr_accessor :log, :filename, :programs, :bundle

    attr_reader :bundle, :filename, :filter, :filtername, :sha1, :valid, :filesize, :updated, :multiplicates, :errors
  
    START_REGEX = /^(\s*Prog\s\d{4,}|\s*\d{5,6}\s+Date : \d{2}.\d{2}.\d{2} \d{2}:\d{2}:\d{2})/
    $start_diag ='^\s*\d{5,6}\s+Date : \d{2}.\d{2}.\d{2} \d{2}:\d{2}:\d{2}'
  
    # Diag format 1
    #  02168  Date : 21.06.94 08:43:16  LC : Z  IQ : 00
    #  Lat1 : ???????  Lon1 : ????????  Lat2 : ???????  Lon2 : ????????
    #  Nb mes : 002  Nb mes>-120dB : 000  Best level : -125 dB
    #  Pass duration : 113s   NOPC : 0
    #  Calcul freq : 401 650000.0 Hz   Altitude :    0 m
    #  24551           00          137
    #$FORMAT_1 = '\s*\d{5,6} +Date : (0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.\d{2} ([0-1][0-9]|2[0-3]):([0-5][0-9]:[0-5][0-9]) +LC : (3|2|1|0|A|B|Z) +IQ : *\d{2} *Lat1 : +((\d+\.\d{3}[NS])|\?)+ +Lon1 : +((\d+\.\d{3}[EW])|\?+) +Lat2 : +((\d+\.\d{3}[NS])|\?+) +Lon2 : +((\d+\.\d{3}[EW])|\?+) +Nb mes : (\d{3})? +Nb mes>-120dB : (\d{3})? +Best level : (-\d{3})? *dB +Pass duration : *(\d+|\?+) *s? +NOPC : +([0-4]|\?) +Calcul freq : +\d{3} (\d+\.\d+)? *Hz +Altitude : +(\d+)? m( +(\d{2,5}|\w{2}))*$'
    $FORMAT_1 =' *\d{5,6} +Date : (0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.\d{2} ([0-1][0-9]|2[0-3]):([0-5][0-9]:[0-5][0-9]) +LC : (3|2|1|0|A|B|Z) +IQ : *\d{2} *Lat1 : +((\d+\.\d{3}[NS])|\?+) +Lon1 : +((\d+\.\d{3}[EW])|\?+) +Lat2 : +((\d+\.\d{3}[NS])|\?)+ +Lon2 : +((\d+\.\d{3}[EW])|\?+) +Nb mes : (\d{3})? +Nb mes>-120dB : (\d{3})? +Best level : (-\d{3})? *dB +Pass duration : *(\d+|\?+) *s? +NOPC : *([0-4]|\?)? +Calcul freq : +\d{3} (\d+\.\d+)? *Hz +Altitude : +(\d+)? m( +.+E[+-]\d+)?( +(\d{2,5}|\w{2}))*'
  
  
    # 09689  Date : 01.02.90 08:35:35  LC : 0  LI : -7
    # Lat1 : 76.304N  Lon1 :  18.925E  Lat2 : 75.769N  Lon2 :  21.554E
    # Nb mes : 004  Nb mes>-120Db : 000  Best level : -130 Db
    # Pass duration : 426s   Dist track :   0
    # Calcul freq : 401 649507.6Khz   Altitude :    0 m
    # -.81408E+1           03           70
    $FORMAT_2 = '\s*\d{5,6} +Date : (0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.\d{2} ([0-1][0-9]|2[0-3]):([0-5][0-9]:[0-5][0-9]) +LC : (3|2|1|0|A|B|Z) +(LI : *\-?\d+)? *Lat1 : +\d+\.\d{3}[NS] +Lon1 : +\d+\.\d{3}[EW] +Lat2 : +\d+\.\d{3}[NS] +Lon2 : +\d+\.\d{3}[EW] +Nb mes : \d{3} +Nb mes>-120(Db|dB) : \d{3} +Best level : -\d{3}? *(Db|dB) +Pass duration : +\d+s +Dist track : +\d+ +Calcul freq : +\d{3} \d+\.\d+ *(Khz|Hz) +Altitude : +\d+ m+(.+E[+-]\d+)*( +(\d{2,5}|\w{2}))*$'
  
  
    # 09689  Date : 01.02.90 08:35:35  LC : 0  IQ : 00
    # Lat1 : 76.304N  Lon1 :  18.925E  Lat2 : 75.769N  Lon2 :  21.554E
    # Nb mes : 004  Nb mes>-120Db : 000  Best level : -130 Db
    # Pass duration : 426s  NOPC :
    # Calcul freq : 401 649507.6Khz   Altitude :    0 m
    # 03           70
    $FORMAT_3 =' *\d{5,6} +Date : (0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.\d{2} ([0-1][0-9]|2[0-3]):([0-5][0-9]:[0-5][0-9]) +LC : (3|2|1|0|A|B|Z) +IQ : *\d{2} *Lat1 : +((\d+\.\d{3}[NS])|\?+) +Lon1 : +((\d+\.\d{3}[EW])|\?+) +Lat2 : +((\d+\.\d{3}[NS])|\?)+ +Lon2 : +((\d+\.\d{3}[EW])|\?+) +Nb mes : (\d{3})? +Nb mes>-120dB : (\d{3})? +Best level : (-\d{3})? *dB +Pass duration : *(\d+|\?+) *s? +NOPC : +([0-4]|\?) +Calcul freq : +\d{3} (\d+\.\d+)? *Hz +Altitude : +(\d+)? m +.+E[+-]\d+( +(\d{2,5}|\w{2}))*$'
  
  
    def initialize
      @errors = []
      @programs = []
      @log = Logger.new(STDERR)
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

    # @return []
    def parse(filename=nil)
      if filename.nil?
        filename = @filename
      end
      
      self.clear # Needed if you parse multiple times
      @total = linecount = 0
      @valid = false

      filename = File.realpath(filename)
      @filename = filename
      if filename.nil? or not File.exists? filename
        raise ArgumentError, "Missing ARGOS DS file: \"#{filename}\""
      end
      @sha1 = Digest::SHA1.file(filename).hexdigest 


      valid_file = false

      contact = []
      file = File.open(filename)
      @filesize = file.size
      @updated = file.mtime.utc

      log.debug "Parsing Argos DIAG file #{filename} sha1:#{sha1} (#{filesize} bytes)"
      if filter?
        log.info "Using filter: #{filter}"
      end


      linecount = 0
      match =0
      startline = 0
      contact =""
  
      File.open(filename, :encoding => "iso-8859-1").each do |line|
        line = line.to_s.strip
        linecount+=1
        
        if line =~ /Prog\s(\d{4,})$/
          @program = line.split(" ").last
          log.info "Program: #{@program}"
          @programs << @program
        end
        
        if line =~ START_REGEX
          match+=1
          if contact !=""
            check_format(contact.strip, startline)
          end
          contact = line
          startline = linecount
        else
          contact = contact + " " +line
        end
      end
      
      check_format(contact.strip, startline)
      
      @programs = @programs.uniq
      if filter?
        total = self.size
        filtered = self.select{|diag| filter.call(diag)}    
        log.info "Selected #{filtered.size}/#{total} Argos DIAG segments sha1:#{sha1} #{filename}"
        self.clear
        # programs may be wrong now!
        filtered.each do |filtered|
          self << filtered
        end
      else
        log.info "Parsed #{self.size} Argos DIAG segments sha1:#{sha1} #{filename}"
      end
  
      @multiplicates = group_by { |e| e }.select { |k, v| v.size > 1 }.map(&:first)
      if multiplicates.any?
        #log.warn "#{multiplicates.size} multiplicates in source sha1 #{sha1} #{filename}): #{multiplicates.map {|a|a[:id]} }"
        self.uniq!
        log.info "Unique DIAG messages: #{self.size} sha1: #{sha1} #{filename}"
      end
      self.sort_by! {|diag| diag[:measured]}
    
      self
    end
  
  
  def check_format(contact, line_num)

    if contact =~ /#{$FORMAT_1}/ or contact =~ /#{$FORMAT_2}/ or contact =~ /#{$FORMAT_2}/
      self << create_diag_hash(contact)
      true
    elsif contact =~ /Prog\s\d{5,}$/
      true
    else
      error = "#{filename}:#{line_num} sha1:#{@sha1} Invalid format:\n"  + contact
      @errors << error
      log.error error
      false
    end

  end
  
    #http://www.argos-system.org/files/pmedia/public/r363_9_argos_users_manual-v1.5.pdf p. 48
    #Nb mes : 025 Number of messages received
    #Nb mes>-120 dB: 015 Number of messages received by the satellite at a signal strength greater than -120 decibels
    #Best level : -113 dB Best signal strength, units are dB
    #Pass duration : 900s Time elapsed between the first and last message received by the 
    #satellite
    #NOPC = 4 Number Of Plausibility Checks successful (from 0-4)
    #Calcul Freq : 401 650000.3 Calculated frequency
    #Altitude : 213 m Altitude used for location calculation
    def create_diag_hash(contact="")
      platform = contact[/^(\d{5,})/,1]
      location_data = contact[/Date : (\d{2}.\d{2}.\d{2} \d{2}:\d{2}:\d{2})/,1]
      contact_time = convert_date(location_data) unless location_data ==nil
      lc = contact[/LC : (3|2|1|0|A|B|Z)/,1]
      li = contact[/LI : *(\-?\d+)/,1]
      iq= contact[/IQ : *(\d{2})/,1]
      lat1= contact[/Lat1 : +(\d+\.\d{3}[NS]|\?+)/,1]
      lat1 = coordinate_conv(lat1)
      lon1= contact[/Lon1 : +(\d+\.\d{3}[EW]|\?+)/,1]
      lon1 = coordinate_conv(lon1)
      lat2= contact[/Lat2 : +(\d+\.\d{3}[NS]|\?+)/,1]
      lat2 = coordinate_conv(lat2)
      lon2= contact[/Lon2 : +(\d+\.\d{3}[EW]|\?+)/,1]
      lon2 = coordinate_conv(lon2)
      nb= contact[/Nb mes : (\d{3})/,1]
      nb120= contact[/Nb mes>-120(Db|dB) : (\d{3})/,2]
      best_level= contact[/Best level : (-\d{3})/,1]
      pass_duration= contact[/Pass duration : +(\d+|\?)/,1]
      dist_track= contact[/Dist track : +(\d+)/,1]
      nopc= contact[/NOPC : +([0-4]|\?)/,1]
      nopc = nopc =~/\?+/ ? nil : nopc
      nopc.to_i unless nopc == nil
      frequency = contact[/Calcul freq : +(\d{3} \d+\.\d+)/,1]
      if frequency =~ /[ ]/
        frequency = frequency.split(" ").join("").to_f
      end
      altitude= contact[/Altitude : +(\d+)? m/,1]
      altitude = altitude.to_i unless altitude == nil
  
      data_start = contact.index(" m ")
      sensor_data = contact[data_start+2,contact.length].split(" ") unless data_start == nil
     
      diag = { platform: platform.to_i,
        measured: contact_time,
        lc: lc,
        iq: iq,
        li: li,
        latitude: lat1,
        longitude: lon1,
        latitude2: lat2,
        longitude2: lon2,
        messages: nb.to_i,
        messages_120dB: nb120.to_i,
        best_level: best_level.to_i,
        pass_duration: pass_duration.to_i,
        dist_track: dist_track,
        nopc: nopc.to_i,
        frequency: frequency,
        altitude: altitude,
        sensor_data: sensor_data,
        technology: "argos",
        type: type,
        filename: "file://"+filename,
        #source: "#{sha1}",
      }

      idbase = diag.clone
      idbase.delete :filename
      id = Digest::SHA1.hexdigest(idbase.to_json)

      #diag[:parser] = Argos.library_version
      diag[:id] = id
      #diag[:bundle] = bundle
      if @program
        diag[:program] = @program
      end
      
      
      diag
    end
  
  
    def coordinate_conv (co)
      if co =~ /\?+/
        co = nil
      elsif co =~/N$/ || co =~/E$/
        co=co.chop.to_f
      elsif co =~/S$/ || co =~/W$/
        co = co.chop.to_f
        co = co * -1
      end
    end
  
  
    def convert_date(date)
      timestamp = DateTime.strptime(date, '%d.%m.%y %H:%M:%S').iso8601.to_s
      timestamp['+00:00'] = "Z"
      timestamp
    end
  
    def type
      "diag"
    end

    def messages
      self
    end

    def programs
      @programs ||= []
    end

    def start
      first[:measured]
    end

    def stop
      last[:measured]
    end


    def source
      sha1
    end

  end
end


#52061  Date : 03.10.09 08:41:12  LC : 0  IQ : 58
#      Lat1 : 76.651N  Lon1 :  20.930W  Lat2 : 76.168N  Lon2 :  18.539W
#      Nb mes : 006  Nb mes>-120dB : 000  Best level : -123 dB
#      Pass duration : 441s  NOPC :  2
#      Calcul freq : 401 677543.2 Hz   Altitude :    0 m
#              40           47           00           00
#              00           00           00          240
#              00           00           00           00
#              00           00          185
#52061  Date : 03.10.09 09:47:05  LC : Z  IQ : 38
#      Lat1 : 76.998N  Lon1 :  22.398W  Lat2 : 74.370N  Lon2 :   10.000
#      Nb mes : 003  Nb mes>-120dB : 000  Best level : -129 dB
#      Pass duration : 100s  NOPC :  0
#      Calcul freq : 401 677501.2 Hz   Altitude :    0 m
#              40           35           00           00
#              00           00           00          240
#              00           00           00           00
#              64           00          197
#52061  Date : 03.10.09 10:23:35  LC : Z  IQ : 00
#      Lat1 : ???????  Lon1 : ????????  Lat2 : ???????  Lon2 : ????????
#      Nb mes : 001  Nb mes>-120dB : 000  Best level : -125 dB
#      Pass duration : ???s  NOPC :  ?
#      Calcul freq : 401 677531.1 Hz   Altitude :    0 m
#             168           64           30


#200910Oct.DIA
#: Line: 26132 Invalid format:
#52061  Date : 03.10.09 09:47:05  LC : Z  IQ : 38 Lat1 : 76.998N  Lon1 :  22.398W  Lat2 : 74.370N  Lon2 :   10.000 Nb mes : 003  Nb mes>-120dB : 000  Best level : -129 dB Pass duration : 100s  NOPC :  0 Calcul freq : 401 677501.2 Hz   Altitude :    0 m 40           35           00           00 00           00           00          240 00           00           00           00 64           00          197