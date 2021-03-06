require 'spec_helper.rb'

module Argos
  describe NorthStar4BytesDecoder do
    
    before do
      @n = NorthStar4BytesDecoder.new
      @n.sensor_data = ["02","174","20","184"] #["02","176","46","156"] # message type 2 (set in the first byte)
      @expected_sensor_data = [2, 174, 20, 184]
    end
    
    it "#sensor_data= forces data to array of 10-base integers" do
      expect(@n.sensor_data).to eq(@expected_sensor_data)
    end
    
    describe "#data" do
      context "message type 0: #{[00,01,248,249].to_json}" do
        exp = {:message_type=>0, current_season: 1, activity_count: 248}
        it "#data is a Hash with current_season and activity_count: #{exp.to_json}" do
          @n.sensor_data = [00,01,248,249]
          expect(@n.data).to eq(exp)
        end
      end
      context "message type 1: #{[1,3,245,255].to_json}" do
        exp = {:message_type=>1, transmissions: 1013}
        it "#data is a Hash with transmissions (count): #{exp.to_json}" do
          @n.sensor_data = [1,3,245,255] # 01 03 F5
          # "03F5" == 1013
          expect(@n.data).to eq(exp)
        end
      end
      context "message type 2: #{[02,174,20,184].to_json}" do
        exp = {:message_type=>2, :voltage=>3.48, :temperature=>20}
        # message type 2 is set in the root before block
        it "#data is Hash with voltage and temperature: #{exp.to_json}" do
          expect(@n.data).to eq(exp)
        end
      end
      context "message type 3: #{[03, 02, 162, 163].to_json}" do
        exp = {:message_type=>3, :system_weeks=>2, :system_hours=>162, :run_time => 1797980.16}
        it "#data is Hash with system_weeks, system_hours, and run_time (seconds): #{exp.to_json}" do
          @n.sensor_data = [03, 02, 162, 163] # from documentation
          expect(@n.data).to eq(exp) # Run Time = 1,797,980.16 [sec]
        end
      end
    end

    describe "#temperature (Celsius)" do
      
      context "[+]" do
        it "positive temperature is equal to sensor byte 3 (of 4)" do
          expect(@n.temperature).to eq(@expected_sensor_data[2])
        end
      end
      
      context "[-]" do
        before do
          @n.sensor_data = ["02","176",236,"156"]
        end
        it "negative temperature is the complement of the binary number plus 1" do
          expect(@n.temperature).to eq(-20)
        end
      end
      
    end
    
    describe "#voltage (V)" do
      it "183 = 3.66V" do
        expect(@n.voltage).to eq(3.48)
        @n.sensor_data = [2,183,0,0] # One more test, from the documentation (183 => 3.66)
        expect(@n.voltage).to eq(3.66)
      end
    end
    
  end
end