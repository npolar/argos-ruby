module Argos
  module SensorData
    
    @sensor_data_format = "integer"
    
    attr_reader :sensor_data
    attr_writer :sensor_data_format
    
    # Fixed-length (defaults to 8 bits) binary from integer-forced number
    # @return [String]
    def binary(number, bits=8)
      number.to_i.to_s(2).rjust(bits, "0")
    end
    
    def byte(number)
      binary(number, 8)
    end
    
    # @return [String]   
    def binary_sensor_data
      if sensor_data.size < 3
        raise ArgumentError, "Missing sensor data"
      end      
      sensor_data.map {|sd| binary(sd) }.join("")
    end
    
    # Fixed-length (defaults to 2 digits) hex string from integer-forced number
    # @return [String]
    def hex(number, digits=2)
      number.to_i.to_s(16).rjust(digits, "0")
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
    
    def flip(bin)
      bin.tr("01","10")
    end
    
    
  end
end