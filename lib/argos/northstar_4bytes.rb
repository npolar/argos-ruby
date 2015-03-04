module Argos
  
  # NorthStar 4-bytes sensor data extractor
  #
  # Extracts sensor data from 32 bit / 4 byte sequence (#binary_sensor_data)
  #
  # https://github.com/npolar/api.npolar.no/wiki/Tracking-API-Vendor-North-Star
  class NorthStar4Bytes
    
    include SensorData
    
    # @return [Hash]
    def data
      data = { message_type: message_type }
      if message_type == 2
        data[:temperature] = temperature
      end
      data
    end
    
    def temperature
      if sensor_data[2] <= 127
        sensor_data[2]
      else
        negative_temperature
      end
    end
    
    def message_type
      sensor_data[0]
    end
    
    protected
    
    # Negative numbers: complement (flip) the binary, add 1 (and set to negative)
    def negative_temperature
      -(flip(binary(sensor_data[2])).to_i(2) + 1)
    end
    
  end
end