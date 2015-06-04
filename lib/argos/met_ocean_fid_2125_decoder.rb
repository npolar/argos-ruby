module Argos
  
  # http://www.metocean.com/
  class MetOceanFID2125Decoder
    include SensorData
    
    @sensor_data_format = "hex"
    
    def data
      data = {}
      data_methods.each {|m|
        data[m] = self.send(m) 
      }
      data
    end
    
    def data_methods
      [:checksum, :message_id, :julian_day, :fix_time, :battery_voltage, :internal_temperature, :barometric_pressure, :air_temperature, :latitude, :longitude, :timetofix, :internal_temperature_1, :barometric_pressure_1, :air_temperature_1]
    end
    
    def checksum
      extract(0,7)
    end
    
     # Lowest 8-bit sum of bytes 2 to 31
    def calc_checksum
      m = hex(sensor_data[1..31].reduce(:+)).match(/(?<checksum>[0-9a-f]{2})$/i)
      m[:checksum].to_i(16)
    end
    
    def message_type
      extract(8,9)
    end
    
    def julian_day
      extract(10,18)
    end
    
    def fix_time
      (0.5 * extract(19,24)).round(4)
    end
    
    def battery_voltage
      (0.2 * extract(25,30) + 6).round(4)
    end
    
    def internal_temperature
      0.15 * extract(31,40) - 50
    end
    
    def barometric_pressure
      (0.1 * extract(41,50) + 850).round(4)
    end
    
    def air_temperature
      (0.1 * extract(51,60) - 60).round(4)
    end
    
    def latitude
      (0.0002 * extract(61,80) - 90).round(4)
    end
    
    def longitude
      (0.0002 * extract(81,101) - 180).round(4)
    end

    def time_to_fix
      16 * extract(102,105)
    end
    
    def internal_temperature_1
      (0.15 * extract(106,114) - 50).round(4)
    end
    
    def barometric_pressure_1
      (0.1 * extract(98,105) + 850).round(4)
    end
    
    def air_temperature_1
      (0.1 * extract(98,105) - 60).round(4)
    end
    
    # latitude_1
    # longitude_1
    # internal_temperature_2
    # barometric_pressure_2
    # air_temperature_2
    # latitude_2
    # longitude_2
    
  end
end