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
  class KiwiSat303Decoder
    
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
  
end