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
    
    # Negative numbers: complement the number and then add a one to the result
   # , remembering to append the negative sign to the number. For example, signed integer ECH is converted to a "signed" number as follows,
#
#              ECH = 1110 1100   (binary)
#    Complement of ECH = 0001 0011
#Two's complement of ECH = (-) (0001 0011) + (0000 0001) = (-) (0001 0100) (binary) = (-) 14H (hexadecimal) = (-) 20 (decimal)
    
    def negative_temperature
      b = - (flip(binary(sensor_data[2])).to_i(2) + 1)
    end
    
  end
end