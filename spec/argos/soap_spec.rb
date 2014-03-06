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
          filename = "getXml-raw.txt"
          rawfile = File.expand_path(File.dirname(__FILE__)+"/_soap/#{filename}")
          File.read(rawfile)
        end
        
        def lastSatellitePass
          {"satellite"=>"NP", "bestMsgDate"=>"2014-03-05T10:37:18.000Z", "duration"=>"183", "nbMessage"=>"3", "message120"=>"0", "bestLevel"=>"-133", "frequency"=>"4.0163995497E8", "location"=>{"locationDate"=>"2014-03-05T10:36:47.000Z", "latitude"=>"77.5266", "longitude"=>"17.60675", "altitude"=>"44.0", "locationClass"=>"A", "diagnostic"=>{"latitude2"=>"74.0082", "longitude2"=>"0.82916", "altitude2"=>"0.0", "index"=>"8", "nopc"=>"3", "errorRadius"=>"0.0", "semiMajor"=>"0.0", "semiMinor"=>"0.0", "orientation"=>"87.0", "hdop"=>"542"}}, "message"=>[{"bestDate"=>"2014-03-05T10:35:16.000Z", "compression"=>"1", "collect"=>{"type"=>"L", "alarm"=>"N", "concatenated"=>"N", "date"=>"2014-03-05T10:35:16.000Z", "level"=>"-136.0", "doppler"=>"-5232.054", "rawData"=>"2800006E729E03"}, "format"=>{"formatOrder"=>"1", "formatName"=>"FORMAT TEMPL. TELONICS-1-7-16-8 #1", "sensor"=>[{"order"=>"1", "name"=>"LOW VOLTAGE FLAG", "valueType"=>"I", "value"=>"0"}, {"order"=>"2", "name"=>"TEMPERATURE", "valueType"=>"I", "value"=>"40"}, {"order"=>"3", "name"=>"ACTIVITY", "valueType"=>"I", "value"=>"0"}, {"order"=>"4", "name"=>"ERROR DETECTION BYTE", "valueType"=>"I", "value"=>"110"}]}}, {"bestDate"=>"2014-03-05T10:37:18.000Z", "compression"=>"1", "collect"=>{"type"=>"L", "alarm"=>"N", "concatenated"=>"N", "date"=>"2014-03-05T10:37:18.000Z", "level"=>"-133.0", "doppler"=>"-13160.484", "rawData"=>"2800006E3B65C0"}, "format"=>{"formatOrder"=>"1", "formatName"=>"FORMAT TEMPL. TELONICS-1-7-16-8 #1", "sensor"=>[{"order"=>"1", "name"=>"LOW VOLTAGE FLAG", "valueType"=>"I", "value"=>"0"}, {"order"=>"2", "name"=>"TEMPERATURE", "valueType"=>"I", "value"=>"40"}, {"order"=>"3", "name"=>"ACTIVITY", "valueType"=>"I", "value"=>"0"}, {"order"=>"4", "name"=>"ERROR DETECTION BYTE", "valueType"=>"I", "value"=>"110"}]}}, {"bestDate"=>"2014-03-05T10:38:19.000Z", "compression"=>"1", "collect"=>{"type"=>"L", "alarm"=>"N", "concatenated"=>"N", "date"=>"2014-03-05T10:38:19.000Z", "level"=>"-139.0", "doppler"=>"-16021.284", "rawData"=>"2800006EACB391"}, "format"=>{"formatOrder"=>"1", "formatName"=>"FORMAT TEMPL. TELONICS-1-7-16-8 #1", "sensor"=>[{"order"=>"1", "name"=>"LOW VOLTAGE FLAG", "valueType"=>"I", "value"=>"0"}, {"order"=>"2", "name"=>"TEMPERATURE", "valueType"=>"I", "value"=>"40"}, {"order"=>"3", "name"=>"ACTIVITY", "valueType"=>"I", "value"=>"0"}, {"order"=>"4", "name"=>"ERROR DETECTION BYTE", "valueType"=>"I", "value"=>"110"}]}}]}
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
        
        response.should_receive(:raw).with().at_least(:once).and_return(body)
        
        soap.getXml["data"]["program"]["platform"].last["satellitePass"].last.should == lastSatellitePass
        
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