module Argos
  
  # KiwiSat 303 sensor data extractor
  #
  # The sensor data consists of a 24 bit / 3 byte sequence (#binary_sensor_data)
  #
  # Binary sensor data, from left:
  # * [00..02] = message_type (0 is a data message, 2 and 7 ("10" and "111") are engineering diagnostics 
  # * [03..06] = voltage
  # * [07..11] = transmissions (count)
  # * [12..20] = temperature
  # * [21..23] = day type (transmission scheduling)
  class Kiwisat303
    
    include SensorData
    
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
    
    # Set sensor data, as one of:
    # * array of numbers (integers)
    # * array of strings containing integers or 2-digit hex numbers (*)
    # * hex string
    # 
    # If you set sensor data as array of hex strings, you must also set sensor_data_format to "hex"
    #
    # @param [Array<String|Integer> | String ] 
    def sensor_data=(sensor_data)
      
      # Hex string?
      if sensor_data.is_a? String
        bytes = (sensor_data.size/2)
        sensor_data = sensor_data.scan(/[0-9a-f]{2}/i)
        if not sensor_data.size == bytes
          raise ArgumentError, "Invalid hex in sensor data string"
        end
        @sensor_data_format = "hex"
      end
      
      # At least 3 members?
      if not sensor_data.is_a? Array or sensor_data.size < 3
        raise ArgumentError, "Sensor data should be an Array of at least 3 scalar elements"
      end
      
      # Hex sensor data?
      if sensor_data.all? {|sd| sd.to_s =~ /^[0-9a-f]{2}$/i }
        if "hex" == @sensor_data_format
          sensor_data = sensor_data.map {|sd| sd.to_s.to_i(16)}
        end
      end
      
      # Convert integers-in-string to integers
      sensor_data = sensor_data.map {|d|
        if d.is_a? String and d.to_s =~ /^[0-9]{1,3}$/i and d.to_i <= 255
          d = d.to_i
        end
        d        
      }
      
      # Validate, all members should now be integers between 0 and 255
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
    # R: temperature <- bin2dec(substr(bin,13,21))
    # R: temperature <- (0.00000015762 * (temperature^3)) - (0.0001034 * (temperature^2)) + (0.1213*temperature) - 10.045
    
    # @return [Integer]
    def message_type
      binary_sensor_data[0..2].to_i(2)
    end
    
    # @return [Integer]
    def transmissions
      binary_sensor_data[7..11].to_i(2)*128
    end
    # R: transmissions <- bin2dec(substr(bin,8,12)) * 128
        
    # @return [Float]
    def voltage
      (binary_sensor_data[3..6].to_i(2) * 0.064 + 2.704).round(4)
    end
    # R: voltage <- bin2dec(substr(bin,4,7)) * 0.064 + 2.704
    
  end
  
  class KiwiSat303  < Kiwisat303
  end
  
end