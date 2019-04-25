module Argos
  
  # Decodes 31 bytes of hex string data for MetOcean Argos buoy using the FID2125 data transmission format
  # http://www.metocean.com/
  class MetOceanFID2125Decoder
    include SensorData
    
    @sensor_data_format = "hex"
    
    # Lowest 8-bit sum of bytes 2 to 31
    def calc_checksum
      m = hex(sensor_data[1..31].reduce(:+)).match(/(?<checksum>[0-9a-f]{2})$/i)
      m[:checksum].to_i(16)
    end
    
    def data
      data = {}
      
      if @sensor_data.size < 31
        #noop
        log.warn "Dismissing sensor data; expected 31 bytes of sensor data, got: #{@sensor_data.size}"
      else
        data_methods.each {|m|
          data[m] = self.send(m) 
        }
        #log.debug data
      end
      data
    end
    
    def data_methods
      [:checksum, :message_code, :julian_day, :fix_time, :battery_voltage,
       :internal_temperature, :internal_temperature1, :internal_temperature2,       
       :barometric_pressure, :barometric_pressure1, :barometric_pressure2,
       :air_temperature, :air_temperature1, :air_temperature2,
       :latitude, :longitude, :latitude1, :longitude1, :latitude2, :longitude2,
       :time_to_fix]
    end
    
    def checksum # 8
      extract(0,7)
    end
    
    def message_code # 2
      extract(8,9)
    end
    
    def julian_day # 9
      extract(10,18)
    end
    
    def fix_time # 6
      (0.5 * extract(19,24)).round(4)
    end
    
    def battery_voltage # 6
      bv = extract(25,30)
      bv.nil? ? nil : (0.2 * bv + 6).round(4)      
    end
    
    def internal_temperature # 9
      x = extract(31,39)
      x.nil? ? nil : it(x)
    end
    
    def barometric_pressure # 11
      bp extract(40,50)
    end
    
    def air_temperature # 10 
      at extract(51,60)
    end
    
    def latitude # 20
      lat extract(61,80)
    end
        
    def longitude # 21
      lng extract(81,101)
    end

    def time_to_fix # 4
      16 * extract(102,105)
    end
    
    def internal_temperature1 # 9
      it extract(106,114)
    end
    
    def barometric_pressure1 #11
      bp extract(115,125)
    end
    
    def air_temperature1 #10
      at extract(126,135)
    end
    
    def latitude1 # 20
      lat extract(136,155)
    end
    
    def longitude1 #21
      lng extract(156,176)
    end
    
    def internal_temperature2 #9
      it extract(177,185)
    end
    
    def barometric_pressure2 #11
      bp extract(186,196)
    end
        
    def air_temperature2 #10
      at extract(197,206)
    end
    
    def latitude2 # 20
      lat extract(207,226)
    end
    
    def longitude2 # 21
      lng extract(227,247)
    end
        
    protected
    
    def at(x)
      (0.1 * x - 60).round(4)
    end
    
    def it(x)
      (0.15 * x - 50).round(4)
    end
  
    def bp(x)
      (0.1 * x + 850).round(4)
    end
    
    def lat(x)
      (0.0002 * x - 90).round(6)
    end
    
    def lng(x)
     (0.0002 * x - 180).round(6)
    end
      
  end
end