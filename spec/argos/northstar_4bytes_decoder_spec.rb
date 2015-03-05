require 'spec_helper.rb'

module Argos
  describe NorthStar4Bytes do
    
    before do
      @n = NorthStar4Bytes.new
      @n.sensor_data = ["02","176","46","156"]
      @expected = [2, 176, 46, 156]
    end
    
    it "sensor_data is forced to arpray of 10-base integers" do
      expect(@n.sensor_data).to eq(@expected)
    end
    
    it "#data returns a Hash with :message_type and :temperature" do
      expect(@n.data).to eq({:message_type=>2, :temperature=>46})
    end
    
    context "#temperature" do
      
      context "[+]" do
        it "positive temperature is equal to the 3rd byte of 4" do
          expect(@n.temperature).to eq(@expected[2])
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
    
  end
end