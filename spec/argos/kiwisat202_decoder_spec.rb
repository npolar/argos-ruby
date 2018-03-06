require 'spec_helper.rb'

module Argos
  describe KiwiSat202Decoder do

    describe "#data" do

      context "message type 0 [16-base] sensor_data = \"131A15\"" do

        before do
          @decoder = Argos::KiwiSat202Decoder.new
          @decoder.sensor_data = "131A15"
          @expected = { :message_type=>0,
            :temperature=>26.25,
            :battery_voltage=>3.4,
            :transmitter_current=>207.5
          }
        end

        describe "#sensor_data" do
          it { expect(@decoder.sensor_data).to eq([19, 26, 21]) }
        end

        describe "#data" do
          it { expect(@decoder.data).to eq(@expected) }
        end

      end

      context "message type 1 [16-base] sensor_data = \"255B3A\"" do

        before do
          @decoder = Argos::KiwiSat202Decoder.new
          @decoder.sensor_data = "255B3A"
          @expected = {
            message_type: 1,
            activity_today: 21,
            activity_yesterday: 54,
            activity_3_days_ago: 58
          }
        end

        describe "#sensor_data" do
          it { expect(@decoder.sensor_data).to eq( [37, 91, 58]) }
        end

        describe "#data" do
          it { expect(@decoder.data).to eq(@expected) }
        end
      end
    end
  end
end
