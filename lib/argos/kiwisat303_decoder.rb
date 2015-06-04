module Argos
  
  # [Kiwisat303Decoder](https://github.com/npolar/argos-ruby/blob/master/lib/argos/kiwisat303_decoder.rb)
  #
  # [KiwiSat 303](http://www.sirtrack.com/images/pdfs/303_K3HVHF.pdf) sensor data decoder
  #
  # Message specification courtesy of Sirtrack
  # The sensor data consists of a 24 bit / 3 byte sequence (See #binary_sensor_data from SensorData module)
  #
  # Transmission format is: "GEN-31*8BITS A2", in Argos data XML //message/format/name:
  # "FORMAT+TEMPL.+31X8-A1+#1" / "FORMAT TEMPL. 31X8-A2-HEXA #1"
  #
  # Four message types exists: data messages (type 0 and 2) and engineering messages (type 6 and 7).
  # Note message types 1,3,5 may also occur
  # Type distribution (N=131533): 0 (58481) 2 (43875) 6 (13591) 7 (13345) 3 (362) 4 (308) 1 (279) 5 (69)
  class KiwiSat303Decoder
    
    include SensorData
    
    # @return [Hash]
    def data
      { message_type: message_type }.merge(message_hash)
    end
    
    # return [String] Schedule type { "A","B","C" }
    # Bits 21-23 – There are three ‘hourly schedule’ types.
    # ‘Hourly Schedule A’ (1)
    # ‘Hourly Schedule B’ (2)
    # ‘Hourly Schedule C’ (3)
    # These allow three different types of user configurable schedules that are followed for that day.
    # So if this message arrives on May 2, with bits 21-23 having a value of 2. This would mean the KS303
    # on May 2 is following the transmission schedule configuration stored as ‘Hourly Schedule B’ for the
    # entire day.
    # 1=A
    # 2=B
    # 3=C
    def schedule
      binary_sensor_data[21..23].to_i(2).to_s.tr("123", "ABC")
    end
    
    # @return [Float] Temperature in Celsius
    # Bits 12-20 – This is the ambient temperature during transmission.
    # Temperature range is -10C to +45C. To convert the raw reading (x) to temperature in Celsius (y) use
    # this equation for best accuracy (+/- 0.1C resolution over entire range, accuracy ~+/- 1 degree over
    # entire range):
    # y = 1.5762E-07x3
    # - 1.0340E-04x2
    # + 1.2130E-01x - 1.0045E+01
    def temperature
      t = binary_sensor_data[12..20].to_i(2)
      t = (0.00000015762 * (t**3)) - (0.0001034 * (t**2)) + (0.1213*t) - 10.045
      t.round(1)
    end
    # R: temperature <- bin2dec(substr(bin,13,21))
    # R: temperature <- (0.00000015762 * (temperature^3)) - (0.0001034 * (temperature^2)) + (0.1213*temperature) - 10.045
    
    # @return [Integer] Message type ∈ {1, 2, 3, 4, 5, 6, 7 }
    # Bits 0-2 – The message type
    def message_type
      binary_sensor_data[0..2].to_i(2)
    end
    
    # @return [Integer] Transmission count
    # Bits 7 – 11 – Multiply the value by 128 to get part of the transmission count.
    # This value must be added to the number of transmissions in the latest message type 7 received to give
    # an approximation of the number of transmitted messages.
    def transmissions
      binary_sensor_data[7..11].to_i(2)*128
    end
    # R: transmissions <- bin2dec(substr(bin,8,12)) * 128
        
    # @return [Float] Voltage in Volt
    # Bits 3-6 – Multiply the decimal value by 0.064 and then add the product to 2.704 to get the battery
    # voltage. (This is the battery voltage during a transmission).
    def battery_voltage
      (binary_sensor_data[3..6].to_i(2) * 0.064 + 2.704).round(3)
    end
    # R: voltage <- bin2dec(substr(bin,4,7)) * 0.064 + 2.704
    
    protected
    
    def message_hash(type=nil)
      
      type = type.nil? ? message_type : type
      
      case type
      when 0
        message_hash_0
      when 1,3,4,5
        {}
      when 2
        message_hash_2
      when 6
        message_hash_6
      when 7
        message_hash_7
      else
        raise ArgumentError, "Unknown message type: #{message_type}"
      end
    end
      
    # Message Type 0 (temperature, voltage, transmissions, schedule)
    # Binary sensor data, counting from 0 and from left (the most significant bit first):
    # * [00..02] = message_type ("000" or 0)
    # * [03..06] = battery voltage [V]
    # * [07..11] = transmissions (count)
    # * [12..20] = temperature [Celsius]
    # * [21..23] = schedule (1,2,3)
    #
    # 0-2 Message Type The message type being transmitted, in this case "000" binary
    # 3-6 Battery Voltage 0.064 volt step measurements. Calculation: 2.704 + (value multiplied by 0.064)
    # 7-11 # Transmissions Multiply value by 128 to get transmission count.
    # 12-20 Temperature -10 C to +45 C with an accuracy of 0.1 C
    # 21-23 Day type The current day type being used to plan transmission, there are 3 possible day types.
    def message_hash_0
      { battery_voltage: battery_voltage,
        transmissions: transmissions,
        temperature: temperature,
        schedule: schedule
      }
    end
    
    # Message Type 2 (activity counters)
    # Binary sensor data, counting from 0 and from left (the most significant bit first):
    # * [00..02] = message_type ("010" or 2)
    # * [03..09] = activity_today (from 00:00 UTC)
    # * [10..16] = activity_yesterday
    # * [17..23] = activity_3_days_ago
    #
    # Bits 0-2 – The message type
    # Bits 3-9 – The total activity for the immediate past day.
    # Bits 10-16 – The total activity for the day 2 days ago.
    # Bits 17 -23 – The total activity for the day 3 days ago.
    # To reduce the overall activity count, the firmware turns on the sensor for 1/4 second every 2 1/2
    # seconds (i.e. 10% duty cycle).
    # Once per hour, firmware scales the total number of switch transitions to a useable range.
    # The hourly activity counts are added together to yield a daily activity total.
    # As there are 7 bits, 127 is the maximum value to transmit per day. (0-127).
    # No activity = 0. Medium activity= ~50. Maximum activity = 127.
    # The 24 hour activity periods are from 0000UTC to the next 0000UTC (the KS303 real-time clock is set
    # to UTC).
    # The activity measurements are gathered and recorded completely independent of whether or not the tag
    # is actually transmitting over Argos. So transmitting (for example) every third day is not an issue.
    #
    # Please be aware that there is no error checking done on the transmission of this data, so you will get errors at times due to 'noise' in the Argos transmissions.
    # For example you may get a decoded set of values for activity and then on a later transmission (the same day) you may see one of the numbers change, and then next transmission return to the previous values.
    # As the activity values are only updated at 0000UTC daily it is therefore obvious that the data with the changed value was in fact erroneous data.
    def message_hash_2
      { activity_today:  binary_sensor_data[3..9].to_i(2),
        activity_yesterday: binary_sensor_data[10..16].to_i(2),
        activity_3_days_ago: binary_sensor_data[17..23].to_i(2)
      }
    end
    
    # 0-2 Message Type ("110" binary or 6)
    # 3-9 Battery voltage 8mV step measurements. Calculation: 2.7 + (value multiplied by 0.008)
    # 10-16 Battery current 8mA step measurements, on the range 0 to 504mA. Calculation: Multiply value by 0.008 to get battery I in Amps
    # 17-23 Reflection Coefficient 0 to 127 units
    def message_hash_6
      { battery_voltage:  2.7 + binary_sensor_data[3..9].to_i(2)*0.008,
        battery_current: (binary_sensor_data[10..16].to_i(2)*0.008).round(3),
        reflection_coefficient: binary_sensor_data[17..23].to_i(2)
      }
    end
    
    # 0-2 Message Type ("111" binary or 7)
    # 3-7 Hour 0 to 23
    # 8-13 Minute 0 to 59
    # 14-19 Seconds 0 to 59
    # 20-23 # Transmissions Multiply value by 4096 to get transmission count.
    def message_hash_7
      { sensor_hour:  binary_sensor_data[3..7].to_i(2),
        sensor_minute: binary_sensor_data[8..13].to_i(2),
        sensor_second: binary_sensor_data[14..19].to_i(2),
        transmissions_total: binary_sensor_data[20..23].to_i(2)*4096
      }
    end

  end
  
end