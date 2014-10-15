require 'spec_helper.rb'

module Argos
  describe Soap do
    
    describe "#getXml" do
      
      before do
        def xmlRequest(merge={})
          { xmlRequest: { :username=>"u1", :password=>"p1", :programNumber=>"9999", :nbDaysFromNow=>20,
            :displayLocation=>true, :displayDiagnostic=>true, :displayMessage=>true, :displayCollect=>true,
            :displayRawData=>true, :displaySensor=>true, :displayImageLocation=>true, :displayHexId=>true }
          }.merge(merge)
        end
        
        def body
          filename = "getXml.xop"
          rawfile = File.expand_path(File.dirname(__FILE__)+"/_soap/#{filename}")
          File.read(rawfile)
        end
        
      end
      
      it "should extract data Hash from raw response" do
        soap = Soap.new(username: "u1", password: "p1")
        client = double("client")
        operation = double("operation")
        
        soap.client = client
        soap.programNumber = "9999"
        
        response = double("response")
        
        client.should_receive(:operation).with(:DixService, :DixServicePort, :getXml).and_return(operation)
        operation.should_receive(:body=).with(xmlRequest)
        operation.should_receive(:call).and_return(response)
        
        response.should_receive(:raw).with(no_args()).at_least(:once).and_return(body)
        
        soap.getXml["data"]["program"]["platform"].should == {"platformId"=>"105605", "platformType"=>"GULL", "platformModel"=>"M-9.5GS", "platformHexId"=>"4F0F25F", "satellitePass"=>{"satellite"=>"NK", "bestMsgDate"=>"2014-09-25T16:53:52.000Z", "duration"=>"0", "nbMessage"=>"1", "message120"=>"0", "bestLevel"=>"-136", "frequency"=>"4.016759502E8", "message"=>{"bestDate"=>"2014-09-25T16:53:52.000Z", "compression"=>"1", "collect"=>{"type"=>"L", "alarm"=>"N", "concatenated"=>"N", "date"=>"2014-09-25T16:53:52.000Z", "level"=>"-136.0", "doppler"=>"27793.756", "rawData"=>"4DD28F"}, "format"=>{"formatOrder"=>"1", "formatName"=>"NORMAL FRAME #1", "sensor"=>[{"order"=>"1", "name"=>"TEMPERATURE", "valueType"=>"I", "value"=>"77"}, {"order"=>"2", "name"=>"BATTERY VOLTS", "valueType"=>"I", "value"=>"210"}, {"order"=>"3", "name"=>"COUNTER", "valueType"=>"I", "value"=>"2"}, {"order"=>"4", "name"=>"ACTIVITY", "valueType"=>"I", "value"=>"15"}]}}}}
        
      end
      
      #it should raise Argos::Exception if blal is not XML
      
      context "no ProgramNumber (and no platformId)" do
        it "should fetch all program numbers"
          #client.should_receive(:operation).with(:DixService, :DixServicePort, :getPlatformList).and_return(operation)
          #
          #operation.should_receive(:body=).with({:platformListRequest=>{:username=>__FILE__, :password=>__FILE__}})
          #operation.should_receive(:call)
          #soap.should_receive(:platforms).and_return(["1","2","3"])
      end
    end
  end
end