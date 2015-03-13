require 'spec_helper.rb'

module Argos
  describe KiwiSat303Decoder do
    
    describe "#data" do

      context "message type 0" do
        
        before do
          @kiwisat = Argos::KiwiSat303Decoder.new
          @kiwisat.sensor_data = [27, 150, 201]
          @expected = { message_type: 0, battery_voltage: 3.536, transmissions: 3200, temperature: 13.0, schedule: "A" }
        end
        
        describe "#sensor_data" do
          it { expect(@kiwisat.sensor_data).to eq([27, 150, 201]) }
        end
        
         describe "#data" do
          it { expect(@kiwisat.data).to eq(@expected) }
        end
        
        describe "#schedule 1" do
          it { expect(@kiwisat.schedule).to eq(@expected[:schedule]) }
        end

        describe "#binary_sensor_data" do
          it { expect(@kiwisat.binary_sensor_data).to eq("000110111001011011001001") }
        end

        describe "#message_type" do
          it { expect(@kiwisat.message_type).to eq(0) }
        end
      
        describe "#temperature" do
          it { expect(@kiwisat.temperature).to eq(@expected[:temperature]) }
        end
            
        describe "#transmissions" do
          it { expect(@kiwisat.transmissions).to eq(@expected[:transmissions]) }
        end
      
        describe "#battery_voltage" do
          it { expect(@kiwisat.battery_voltage).to eq(@expected[:battery_voltage]) }
        end
      
      end
    
      context "message type 2" do
          
        before do
          @kiwisat = Argos::KiwiSat303Decoder.new
          @kiwisat.sensor_data = "464F96C20F98CD8BE2C02FE5D56BC9DFE6A0D836876F2796443FF8"
          @expected = {:message_type=>2, :activity_today=>25, :activity_yesterday=>31, :activity_3_days_ago=>22}
        end
          
        describe "#sensor_data (from hex string \"464F96C20F98CD8BE2C02FE5D56BC9DFE6A0D836876F2796443FF8\")" do
          it { expect(@kiwisat.sensor_data).to eq([70, 79, 150, 194, 15, 152, 205, 139, 226, 192, 47, 229, 213, 107, 201, 223, 230, 160, 216, 54, 135, 111, 39, 150, 68, 63, 248]) }
        end
          
        describe "#data" do
          it { expect(@kiwisat.data).to eq(@expected) }
        end
        
        describe "#message_type" do
          it { expect(@kiwisat.message_type).to eq(2) }
        end
          
      end
      
      context "message type 6" do
          
        before do
          @kiwisat = Argos::KiwiSat303Decoder.new
          @kiwisat.sensor_data =  ["215","73","34"]
          @expected = {:message_type=>6, :battery_voltage =>3.444, :battery_current=>0.144, :reflection_coefficient=>34}
        end
          
        describe "#sensor_data ([215,73,34])" do
          it { expect(@kiwisat.sensor_data).to eq([215,73,34]) }
        end
          
        describe "#data" do
          it { expect(@kiwisat.data).to eq(@expected) }
        end
        
        describe "#message_type" do
          it { expect(@kiwisat.message_type).to eq(6) }
        end
          
      end
      
      context "message type 7" do
          
        before do
          @kiwisat = Argos::KiwiSat303Decoder.new
          @kiwisat.sensor_data = "F0BBA8"
          @expected = {:message_type=>7, :sensor_hour=>16, :sensor_minute=>46, :sensor_second=>58, :transmissions_total => 32768}
        end
          
        describe "#sensor_data (from hex string \"F0BBA8\")" do
          it { expect(@kiwisat.sensor_data).to eq([240,187,168]) }
        end
          
        describe "#data" do
          it { expect(@kiwisat.data).to eq(@expected) }
        end
        
        describe "#message_type" do
          it { expect(@kiwisat.message_type).to eq(7) }
        end
        
      end
      
    end # #data
    
    describe "#sensor_data=" do
      it "Hex arrays when sensor_data_format != \"hex\" raises ArgumentError" do    
        expect {
          kiwisat = Argos::KiwiSat303Decoder.new
          kiwisat.sensor_data = ["AA","BB", "FF"]
          }.to raise_error(ArgumentError)
      end
    
      it "invalid hex should raise ArgumentError" do    
        expect { Argos::KiwiSat303Decoder.new.sensor_data = "46FZ" }.to raise_error(ArgumentError)
      end
    end
      
  end
end