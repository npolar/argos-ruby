require 'spec_helper.rb'

module Argos
  describe KiwiSat303Decoder do
    
    describe "#data" do

      context "message type 0" do
        
        before do
          @kiwisat = Argos::KiwiSat303Decoder.new
          @kiwisat.sensor_data = [27, 150, 201]
          @expected = { message_type: 0, voltage: 3.536, transmissions: 3200, temperature: 13.0187, day_type: 1 }
        end
        
        describe "#sensor_data" do
          it { expect(@kiwisat.sensor_data).to eq([27, 150, 201]) }
        end
        
         describe "#data" do
          it { expect(@kiwisat.data).to eq(@expected) }
        end
        
        describe "#day_type" do
          it { expect(@kiwisat.day_type).to eq(@expected[:day_type]) }
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
      
        describe "#voltage" do
          it { expect(@kiwisat.voltage).to eq(@expected[:voltage]) }
        end
      
      end # message type 0
    
      context "message type 2" do
          
        before do
          @kiwisat = Argos::KiwiSat303Decoder.new
          @kiwisat.sensor_data = "464F96C20F98CD8BE2C02FE5D56BC9DFE6A0D836876F2796443FF8"
          @expected = {:message_type=>2} #{ message_type: 2, voltage: 3.536, transmissions: 3200, temperature: 13.0187, day_type: 1 }
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
          
      end # message type 2
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

# Questions
#
# 11-bytes array ["19", "208", "25", "91", "53", "104", "30", "241", "194", "131", "76"] is still message_type 0 ?
# 113910  11660 77.86706  18.11291           A 2014-12-22T15:44:31Z  NN  NA 19|208|25|91|53|104|30|241|194|131|76          344            1833              64  771     NA Arctic fox
#
# 27-byte type 2?
# "464F96C20F98CD8BE2C02FE5D56BC9DFE6A0D836876F2796443FF8"