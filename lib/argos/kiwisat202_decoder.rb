module Argos

  # [Kiwisat202Decoder](https://github.com/npolar/argos-ruby/blob/master/lib/argos/kiwisat202_decoder.rb)
  #
  # KiwiSat 202 sensor data decoder
  #
  # Message specification courtesy of Sirtrack
  # The sensor data consists of a 24 bit / 3 byte sequence (See #binary_sensor_data from SensorData module)

  class KiwiSat202Decoder

    include SensorData

    # @return [Hash]
    def data
      { message_type: message_type }.merge(message_hash)
    end

    # @return [Integer] Message type ∈ {0,1}
    # First 3 bits
    def message_type
      binary_sensor_data[0..2].to_i(2)
    end

    # @return [Float] Temperature in Celsius (°C)
    # Next 9 bits [starting at +3]
    def temperature
      t = binary_sensor_data[3..11].to_i(2)
      t = (t*0.25)-50
      t
    end

    # @return [Float] Battery voltage (U) in volt (V)
    def battery_voltage
      # Next 6 bits
      v = binary_sensor_data[12..17].to_i(2)
      v = (v*0.05)+1.4
      v
    end

  # @return [Float] Transmitter current (I) in mA
    def transmitter_current
      # Next 6 bits
      v = binary_sensor_data[18..23].to_i(2)
      v = (v*7.5)+50
      v
    end

    protected

    def message_hash(type=nil)

      type = type.nil? ? message_type : type
      case type
      when 0
        message_type_0
      when 1
        message_type_1
      else
        raise ArgumentError, "Unknown message type: #{message_type.to_json}"
      end
    end

    # Message Type 0
    def message_type_0
      {
        temperature: temperature,
        battery_voltage: battery_voltage,
        transmitter_current: transmitter_current
      }
    end

    # Message Type 1 (activity)
    # * [03..09] = activity_today (from 00:00 UTC)
    # * [10..16] = activity_yesterday
    # * [17..23] = activity_3_days_ago
    def message_type_1
      { activity_today:  binary_sensor_data[3..9].to_i(2),
        activity_yesterday: binary_sensor_data[10..16].to_i(2),
        activity_3_days_ago: binary_sensor_data[17..23].to_i(2)
      }
    end

  end

end
