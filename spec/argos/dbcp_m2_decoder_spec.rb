require 'spec_helper.rb'

module Argos
 describe DBCP_M2Decoder do

   describe "#data" do

     context "D94F755D25D30E8E8F113B0168A4BA61D4D1E2B760324974CBA1A3C68EC071" do
       before do
         @dbcpm2 = Argos::DBCP_M2Decoder.new
         @dbcpm2.sensor_data = "D94F755D25D30E8E8F113B0168A4BA61D4D1E2B760324974CBA1A3C68EC071"
         @expected = {:chk=>184, :rank=>4, :ageb=>60, :bp=>918.3, :sst=>21.240000000000002, :apt=>23.6, :at=>43.0}
         @integer = [217, 79, 117, 93, 37, 211, 14, 142, 143, 17, 59, 1, 104, 164, 186, 97, 212, 209, 226, 183, 96, 50, 73, 116, 203, 161, 163, 198, 142, 192, 113]
       end

       #it { expect(@dbcpm2.data).to eq({:chk=>184, :rank=>4, :ageb=>60, :bp=>918.3, :sst=>21.240000000000002, :apt=>23.6, :at=>43.0}) }

       describe "#binary_sensor_data.size" do
         it { expect(@dbcpm2.binary_sensor_data.size).to eq(248) }
       end

       describe "#sensor_data" do
         it { expect(@dbcpm2.sensor_data).to eq(@integer) }
       end

       describe "#chk" do
         it { expect(@dbcpm2.chk).to eq(217) }
       end

       describe "#rank" do
         it { expect(@dbcpm2.rank).to eq(4) }
       end

       describe "#ageb" do
         it { expect(@dbcpm2.ageb).to eq(61) }
       end

       describe "#bp" do
         it { expect(@dbcpm2.bp).to eq(1020.7) }
       end

       describe "#sst" do
         it { expect(@dbcpm2.sst).to eq(21.32) }
       end

       describe "#apt" do
         it { expect(@dbcpm2.apt).to eq(-2.1999999999999993) }
       end

       describe "#at" do
         it { expect(@dbcpm2.at).to eq(36.5) }
       end

       describe "#vbat" do
         it { expect(@dbcpm2.vbat).to eq(6) }
       end

       describe "#tz" do
         it { expect(@dbcpm2.tz).to eq(-4.8) }
       end

        describe "#depth" do
         it { expect(@dbcpm2.depth).to eq(162) }
       end

       describe "#subm" do
         it { expect(@dbcpm2.subm).to eq(33) }
       end

       describe "#wd" do
         it { expect(@dbcpm2.wd).to eq(213) }
       end

       describe "#ws" do
         it { expect(@dbcpm2.ws).to eq(17) }
       end

      describe "#pressures" do
         it { expect(@dbcpm2.pressures).to eq([898.2, 881.5, 851.1, 905.3, 887.2, 1006.5, 911.6, 1043.0, 1027.2, 855.0]) }
       end

     end

   end # #data


 end
end
