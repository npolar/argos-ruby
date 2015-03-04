module Argos
  
  # KiwiSat 303 sensor data extractor
  class Kiwisat303
    
    attr_reader :sensor_data
    
    # Fixed-length (defaults to 8 bits) binary from integer-forced number
    # @return [String]
    def binary(number, bits=8)
      number.to_i.to_s(2).rjust(bits, "0")
    end
    
    # @return [Hash]
    def data
      # @todo This depends on the message type
      { message_type: message_type,
        voltage: voltage, # in V
        transmissions: transmissions,
        temperature: temperature # in Celsius
      }
    end
    
    # return [Integer]
    def day_type
      binary_sensor_data[21..23].to_i(2)
    end
    
    # Set sensor data array of numbers (integers or strings containing integers or 2-digit hex numbers)
    # @param [Array<String|Integer>]
    def sensor_data=(sensor_data)
      # @todo How about real Hex members
      if not sensor_data.is_a? Array or sensor_data.size < 3
        raise ArgumentError, "Sensor data should be an Array of at least 3 scalar elements"
      end
      
      # Hex sensor data?
      if sensor_data.all? {|sd| sd.to_s =~ /^[0-9a-f]{2}$/i }
        sensor_data = sensor_data.map {|sd| sd.to_s.to_i(16)}
      end
      
      # String-bearing integer sensor data?
      sensor_data = sensor_data.map {|d|
        if d.is_a? String and d.to_s =~ /^[0-9]{1,3}$/i and d.to_i <= 255
          d = d.to_i
        end
        d        
      }
      
      if sensor_data.any? {|sd| sd.to_i != sd or sd < 0 or sd > 255 }
        raise ArgumentError, "Invalid sensor data: Not array of integers between 0-255"
      end
      
      @sensor_data = sensor_data  
    end
    
    # @return [Float]
    def temperature
      t = binary_sensor_data[12..20].to_i(2)
      t = (0.00000015762 * (t**3)) - (0.0001034 * (t**2)) + (0.1213*t) - 10.045
      t.round(4)
    end
    # R: tmp <- bin2dec(substr(bin,13,21))
    # R: tmp <- (0.00000015762 * (tmp^3)) - (0.0001034 * (tmp^2)) + (0.1213*tmp) - 10.045
    
    # @return [Integer]
    def message_type
      binary_sensor_data[0..2].to_i(2)
    end
    
    # @return [Integer]
    def transmissions
      binary_sensor_data[7..11].to_i(2)*128
    end
    # R: transmissions <- bin2dec(substr(bin,8,12)) * 128
    
    # @return [String]   
    def binary_sensor_data
      if sensor_data.size < 3
        raise ArgumentError, "Missing sensor data"
      end      
      sensor_data.map {|sd| binary(sd) }.join("")
    end
    
    # @return [Float]
    def voltage
      binary_sensor_data[3..6].to_i(2) * 0.064 + 2.704
    end
    # R: voltage <- bin2dec(substr(bin,4,7)) * 0.064 + 2.704
    
  end
end