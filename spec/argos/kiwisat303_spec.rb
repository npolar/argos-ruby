require 'spec_helper.rb'

module Argos
  describe Kiwisat303 do

    context "sensor data = [27, 150, 201]" do
      
      before do
        @kiwisat = Argos::Kiwisat303.new
        @kiwisat.sensor_data = ["27", "150", 201]
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
          expect(@kiwisat.voltage).to be_within(0.0001).of(@expected[:voltage])
        end
      end
    
    end
  end
end