require 'spec_helper.rb'

module Argos
  describe Kiwisat303 do

    context "sensor data = (integer/string array) [\"27\", 150, 201]" do
      
      before do
        @kiwisat = Argos::Kiwisat303.new
        @kiwisat.sensor_data = ["27", 150, 201]
        @expected = { message_type: 0,
          voltage: 3.536,
          transmissions: 3200,
          temperature: 13.0187,
          day_type: 1
        }
      end
      
      describe "#binary" do
        it "00011011 is binary for 27" do
          expect(@kiwisat.binary(27)).to eq("00011011")
        end
      end
         
      describe "#binary_sensor_data" do
        it do
          expect(@kiwisat.binary_sensor_data).to eq("000110111001011011001001")
        end
      end
      
      describe "#day_type" do
        it do
          expect(@kiwisat.day_type).to eq(@expected[:day_type])
        end
      end

      describe "#temperature" do
        it do
          expect(@kiwisat.temperature).to eq(@expected[:temperature]) #be_within(0.0001).of(@expected[:temperature])
        end
      end
      
      describe "#message_type" do
        it do
          expect(@kiwisat.message_type).to eq(0)
        end
      end
            
      describe "#transmissions" do
        it do
          expect(@kiwisat.transmissions).to eq(@expected[:transmissions])
        end
      end
      
      describe "#voltage" do
        it do
          expect(@kiwisat.voltage).to eq(@expected[:voltage])
        end
      end
      
    end
    
    context "sensor data = (hex string) \"464F96[..]\"" do
      
      before do
        @kiwisat = Argos::Kiwisat303.new
        @kiwisat.sensor_data = "464F96C20F98CD8BE2C02FE5D56BC9DFE6A0D836876F2796443FF8"
        @expected = { message_type: 2,
          voltage: 2.896,
          transmissions: 512,
          temperature: 44.1858
        }
      end
      
      describe "#data" do
        it do
          expect(@kiwisat.data).to eq(@expected)
        end 
      end
      
      describe "#sensor_data" do
        it do
          expect(@kiwisat.sensor_data).to eq([70, 79, 150, 194, 15, 152, 205, 139, 226, 192, 47, 229, 213, 107, 201, 223, 230, 160, 216, 54, 135, 111, 39, 150, 68, 63, 248])
        end
      end
      
      it "invalid hex should raise ArgumentError" do    
        expect { @kiwisat.sensor_data = "46FG" }.to raise_error(ArgumentError)
      end
      
      # Hmm 11-bytes array ["19", "208", "25", "91", "53", "104", "30", "241", "194", "131", "76"] is still message_type 0 ?
      # 113910  11660 77.86706  18.11291           A 2014-12-22T15:44:31Z  NN  NA 19|208|25|91|53|104|30|241|194|131|76          344            1833              64  771     NA Arctic fox
      
    end
    
    
    context "sensor data = (hex array) [\"19\",\"04\", \"A1\"]" do
      
      before do
        @kiwisat = Argos::Kiwisat303.new
        @kiwisat.sensor_data_format="hex"
        @kiwisat.sensor_data = ["19","04", "A1"]
        @expected = {:message_type=>0, :voltage=>3.472, :transmissions=>2048, :temperature=>6.1535}
      end
      
      describe "#data" do
        it do
          expect(@kiwisat.data).to eq(@expected)
        end 
      end
      
      describe "#sensor_data = [25, 4, 161]" do
        it do
          expect(@kiwisat.sensor_data).to eq([25, 4, 161])
        end
      end
      
      it "Hex arrays when sensor_data_format != \"hex\" raises ArgumentError" do    
        expect {
          kiwisat = Argos::Kiwisat303.new
          kiwisat.sensor_data = ["AA","BB", "FF"]
          }.to raise_error(ArgumentError)
      end
      
      
    end
    
  
  end
end