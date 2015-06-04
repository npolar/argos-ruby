require 'spec_helper.rb'

module Argos
  describe MetOceanFID2125Decoder do
    describe "#data" do

      #<locationDate>2015-05-01T00:14:32.000Z</locationDate>
      #<latitude>82.02293</latitude>
      #<longitude>13.67148</longitude>
      #<altitude>0.0</altitude>
      #<locationClass>1</locationClass>

      #<collect>
      #   <type>L</type>
      #   <alarm>N</alarm>
      #   <concatenated>N</concatenated>
      #   <date>2015-05-01T00:09:33.000Z</date>
      #   <level>-129.0</level>
      #   <doppler>3930.684</doppler>
      #   <rawData>B84F155D23D62E2E8FE0BB2064247AC9C5D1FC776439C8F58385A3F9EEC8D0</rawData>
      #</collect>
 

      context "B84F155D23D62E2E8FE0BB2064247AC9C5D1FC776439C8F58385A3F9EEC8D0" do  
        before do
          @metocean = Argos::MetOceanFID2125Decoder.new
          @metocean.sensor_data = "B84F155D23D62E2E8FE0BB2064247AC9C5D1FC776439C8F58385A3F9EEC8D0"
          @expected = {}
          @integer = [184, 79, 21, 93, 35, 214, 46, 46, 143, 224, 187, 32, 100, 36, 122, 201, 197, 209, 252, 119, 100, 57, 200, 245, 131, 133, 163, 249, 238, 200, 208]

        end
        
        #it { expect(@metocean.data).to eq() }
        
        describe "#binary_sensor_data.size" do
          it { expect(@metocean.binary_sensor_data.size).to eq(248) }
        end
        
        describe "#sensor_data" do
          #it { expect(@metocean.sensor_data.reduce(:+)).to eq(4464) }
          it { expect(@metocean.sensor_data).to eq(@integer) }
        end
          
        describe "#data" do
          #it { expect(@metocean.data).to eq([]) }
        end
        
        describe "#checksum == #calc_checksum == 184" do
          it { expect(@metocean.checksum).to eq(@metocean.calc_checksum) }
        end
        
        describe "#message_type" do
          it { expect(@metocean.message_type).to eq(1) }
        end
        
        describe "#julian_day" do
          # 1 May is day 120
          it { expect(@metocean.julian_day).to eq(120) }
        end
        
        describe "#fix_time" do
          it { expect(@metocean.fix_time).to eq(21.0) }
        end
        
        describe "#battery_voltage" do
          it { expect(@metocean.battery_voltage).to eq(15.2) }
        end
        
        describe "#internal_temperature" do
          it { expect(@metocean.internal_temperature).to eq(37.45) }
        end
              
        describe "#barometric_pressure" do
          it { expect(@metocean.barometric_pressure).to eq(918.9) }
        end
        
        describe "#air_temperature" do
          it { expect(@metocean.air_temperature).to eq(-14.7000) }
        end
        
        describe "#latitude" do
          it { expect(@metocean.latitude).to eq(82.0194) }
        end
        
        describe "#longitude" do
          it { expect(@metocean.longitude).to eq(13.7458) }
        end
        
        describe "#time_to_fix" do
          it { expect(@metocean.time_to_fix).to eq(0) }
        end
        
        describe "#internal_temperature_1" do
          it { expect(@metocean.internal_temperature_1).to eq(-6.35) }
        end
         
        describe "#barometric_pressure_1" do
          it { expect(@metocean.barometric_pressure_1).to eq(864.4) }
        end
        
        describe "#air_temperature_1" do
          it { expect(@metocean.air_temperature_1).to eq(-45.6) }
        end

        

    # latitude_1
    # longitude_1
    # internal_temperature_2
    # barometric_pressure_2
    # air_temperature_2
    # latitude_2
    # longitude_2
    
      end
      
    end # #data
    
      
  end
end

