module Argos
  
  # NorthStar 4-bytes sensor data decoder
  #
  # [Documentation](https://raw.githubusercontent.com/npolar/argos-ruby/master/documents/northstarst.com/message-formats-4-byte-sensor-data.txt)
  #
  # Each message consists of a 4-byte data stream, which contains three sections; a message ID, the sensor data, and the message checksum.
  # Thus the 4-byte data stream has the following format;
  #
  # Message Byte	Description
  # 0	Message_ID
  # 1	Sensor_Byte_0
  # 2	Sensor_Byte_1
  # 3	Message_Checksum
  #
  # The following messages are currently used;
  #
  # Message_ID	Sensor_Byte_0	Sensor_Byte_1
  # 00	Current Season	Activity Count
  # 01	Tx Count (MSB)	Tx Count (LSB)
  # 02	Battery Voltage	Temperature (C)
  # 03	System Week	System Hour
  #
  # The message ID is a unique single byte number identifying the sensor data which is contained in the message.
  # For example message 00 will always contain the Current Season (Sensor_Byte_0) and the Activity Count (Sensor_Byte_1).
  # As new sensors become available new unique message IDs will be assigned.

  class NorthStar4BytesDecoder
    
    include SensorData
    
    # @return [Hash]
    def data
      data = { message_type: message_type }
      if message_type == 0
        data[:current_season] = current_season
        data[:activity_count] = activity_count
      elsif message_type == 1
        data[:transmissions] = transmissions    
      elsif message_type == 2
        data[:voltage] = voltage
        data[:temperature] = temperature
      elsif message_type == 3
        data[:system_weeks] = system_weeks
        data[:system_hours] = system_hours
        data[:run_time] = run_time
      end
      data
    end

    def message_type
      sensor_data[0]
    end
    alias :message_id :message_type
    
    # (1) Current Season
    # This is the integer value of the data received.
    def current_season
      sensor_data[1]
    end
    
    # (2) Activity Count
    # This is the integer value of the data received.
    def activity_count
      sensor_data[2]
    end
    
    # (3) Transmission Counter
    # Combine the hexadecimal value of the two bytes received and convert to decimal notation.
    def transmissions
      "#{hex(sensor_data[1])}#{hex(sensor_data[2])}".to_i(16)
    end
        
    # (4) Battery Voltage (volts)
    # Convert the received data (Bat_volt_byte) using the following formula;
    # Battery Voltage = 2 x (Bat_volt_byte) x (0.01)
    #
    # For example, if the Bat_volt_byte received is B7H (i.e. 183 decimal) then the actual battery voltage is
    #
    # Battery Voltage = 2 X (183) X (0.01) (volts)
    # or,
    # Battery Voltage = 3.66 (volts).
    def voltage
      voltage_byte = sensor_data[1]
      2 * voltage_byte * 0.01
    end
    
    # (5) Temperature (Centigrade)
    # This is the signed integer value of the received data in whole degrees. Signed integers use the most significant bit to indicate whether the number is positive (in binary notation bit 7 = 0) or negative (bit 7 = 1).
    # Positive numbers are converted directly to integers. Negative numbers require that a two's complement conversion of the received data be performed to get the signed integer result. In order to perform a two's complement conversion,
    # first complement the number and then add a one to the result, remembering to append the negative sign to the number. For example, signed integer ECH is converted to a "signed" number as follows,
    #
    # ECH = 1110 1100 (binary)
    # Complement of ECH = 0001 0011
    # Two's complement of ECH = (-) (0001 0011) + (0000 0001)
    # = (-) (0001 0100) (binary)
    # = (-) 14H	(hexadecimal)
    # = (-) 20 (decimal)
    #
    # On the other hand, if the temperature data is 14H then since the sign bit (bit 7) is positive the temperature is positive,
    #
    # Temperature = 14H = 0001 0100 (binary) = 20 (decimal)
    # Temperature = (+) 20 centigrade.
    def temperature
      if sensor_data[2] <= 127
        sensor_data[2]
      else
        negative_temperature
      end
    end
    
    # (7) System Week Count
    # This is the integer value of the data received.	Remember a "System Week" is 167 "System Hours". Thus a "System Week" is about 605368.32 standard seconds which is exceeds a standard week by about 568 seconds.
    def system_weeks
      sensor_data[1]
    end
    
    # (6) System Hour Count
    # This is the integer value of the data received. Remember a "System Hour" equals about 3624.96 standard seconds.
    def system_hours
      sensor_data[2]
    end
    
    # Run Time = 2 X (605368.32) + 162 X (3624.96) [sec]
    def run_time
      system_weeks*605368.32 + system_hours*3624.96
    end
    
    protected
    
    # Negative numbers: complement (flip) the binary, add 1 (and set to negative)
    def negative_temperature
      -(flip(binary(sensor_data[2])).to_i(2) + 1)
    end
    
  end
end