#require 'ap'

class Diag

  $start_diag ='^\s*\d{5,6}\s+Date : \d{2}.\d{2}.\d{2} \d{2}:\d{2}:\d{2}'

  #   Format 1
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


  def initialize (filename = nil)
    @index = 0
    @error_num = 0
    @errors_num =0
    @argos_contacts = Array.new
    @filename = filename
    read_file (filename) unless filename == nil

  end

  def get_hash
    @argos_contacts
  end


  def read_file (filename)
    linecount = 0
    match =0
    startline = 0
    contact =""

    File.open(filename, :encoding => 'iso-8859-1').each do |line|
      line = line.to_s.strip
      linecount+=1
      if line =~ /#{$start_diag}/
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
  end


def check_format(contact, line_num)
    if contact =~ /#{$FORMAT_1}/
      @argos_contacts.push(create_diag_hash(contact))
      return true
    elsif
      contact =~ /#{$FORMAT_2}/
      @argos_contacts.push(create_diag_hash(contact))
      return true
    elsif
      contact =~ /#{$FORMAT_3}/
      @argos_contacts.push(create_diag_hash(contact))
      return true
    else
      error = "Line: #{line_num} Invalid format:" + contact
      $log.<<"\n#{error}\n\n",:error, false if $log
      return false
    end

  end


  def create_diag_hash(contact="")
    ptt = contact[/^(\d{5})/,1]
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
    calc_freq= contact[/Calcul freq : +(\d{3} \d+\.\d+)/,1]
    altitude= contact[/Altitude : +(\d+)? m/,1]
    altitude = altitude.to_i unless altitude == nil

    data_start = contact.index(" m ")
    sensor_data = contact[data_start+2,contact.length].split(" ") unless data_start == nil
    contact_hash =Hash.new
    contact_hash = {:system=>"argos",
                    :hardware_id=>ptt,#.to_i,
                    :satellite=>
                    {:latitude=>[lat1, lat2],
                     :longitude=>[lon1,lon2],
                     :altitude=>altitude,
                     :contact_time=>contact_time,
                     :quality=>lc,
                     :best_level=>best_level,
                     :calc_freq =>calc_freq
                     },
                    :diag_sensordata=>sensor_data
                    }

    contact_hash
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




end
