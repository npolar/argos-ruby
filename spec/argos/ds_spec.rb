require 'spec_helper.rb'

module Argos
  

  describe Ds do
    
    VALID_DS = dsfile("990660_A.DAT")

    before (:each) do
      @ds = Ds.new
      @ds.log = Logger.new("/dev/null")     
      @ds.parse(VALID_DS)
    end
  

    describe "#messages" do
      it ".size should == number of messages" do 
        @ds.messages.size.should == 449
      end
    end

    describe "#size" do
      it "should == number of unfolded documents" do
        @ds.size.should == 843
      end
    end

    describe "#type" do
      it do
        Ds.new.type.should == "ds"
      end
    end

    describe "#parse" do
            
      it "should return Argos::Ds Array" do
        @ds.filter = lambda {|ds|true}
        @ds.parse(VALID_DS).should be_kind_of Ds
      end
      
      it "should return unique elements" do
        @ds.parse(dsfile("dup.ds")).size.should == 3 # file contains 6
      end
      
                  
      it "should store multiplicates" do
        @ds.parse(dsfile("dup.ds")).multiplicates.map {|m| m.keys }.should==3.times.map{[:program,
         :platform,
         :lines,
         :sensors,
         :satellite,
         :lc,
         :positioned,
         :latitude,
         :longitude,
         :altitude,
         :headers,
         :measured,
         :identical,
         :sensor_data,
         :technology,
         :type,
         :file,
         :source,
         :parser,
         :id,
         :bundle]}
      end

      it "should sort ascending on positioned, measured" do
        positions = @ds.select {|ds|
          ds.key? :positioned and not ds[:positioned].nil?
        }.map {|ds| ds [:positioned] }
        positions.size.should == 340
        positions.first.should == "1999-12-01T10:23:48Z"
        positions.last.should == "1999-12-31T19:18:58Z"
      end

      it "should create SHA-1 id for each document"    
      #id = Digest::SHA1.hexdigest(t.to_json)

      context "09660 10783   2  3 H A 1999-12-30 18:41:56  79.828   22.319  0.000 401649712    
      1999-12-30 18:43:52  3         78           00           00               
" do
        it do
          @ds.parse(VALID_DS)
          first = @ds.select{ |ds|
            ds[:positioned] == "1999-12-30T18:41:56Z"
          }.should ==  [{:program=>9660, :platform=>10783, :lines=>2, :sensors=>3, :satellite=>"H", :lc=>"A",
:positioned=>"1999-12-30T18:41:56Z", :latitude=>79.828,
:longitude=>22.319, :altitude=>0.0, :headers=>12,
:measured=>"1999-12-30T18:43:52Z", :identical=>3, :sensor_data=>["78", "00", "00"],
:technology=>"argos", :type=>"ds", :file=>"file://"+VALID_DS, :parser => "argos-ruby-#{Argos::VERSION}",
:source=>"3a39e0bd0b944dca4f4fbf17bc0680704cde2994", :id=>"4369c31c191bd55a998e6293ff4639da3984a95d",
:bundle=>nil}]
          end
        end
      end
    
    describe "filtering" do

      it "a filter is a lambda that selects messages" do
        @ds.filter = lambda {|ds| ds[:program] == 660 }
        @ds.parse(VALID_DS).size.should == 1
      end

      it "a filter may also be a string containing a lambda" do
        @ds.filter = 'lambda {|ds| ds[:program] == 660 }'
        @ds.parse(VALID_DS).should ==  [{:program=>660, :platform=>14747,
:lines=>2, :sensors=>32, :satellite=>"K", :lc=>nil, :positioned=>nil,
:latitude=>nil, :longitude=>nil, :altitude=>nil, :headers=>5,
:measured=>"1999-12-16T00:46:49Z", :identical=>1,
:sensor_data=>["92", "128", "130", "132"], :technology=>"argos",
:type=>"ds", :file=> "file://"+VALID_DS,
:source=>"3a39e0bd0b944dca4f4fbf17bc0680704cde2994",
:warn=>["missing-position", "sensors-count-mismatch"],
:parser=>"argos-ruby-#{Argos::VERSION}",
:bundle=>nil,
:id=>"f2c82a5ca1330b312925949a15ac300d07452a12"}]
      end

    end

    #context "errors" do

    context "warn" do

      before(:each) do
        @file = dsfile("sensor_mismatch_ds.txt")
      end

      it "sensors-count-mismatch" do
        @ds.parse @file
        @ds[1][:warn].should_not include("sensors-count-mismatch")
        @ds[2][:warn].should include("sensors-count-mismatch")  
      end

      it "missing-position"  do
          @ds.parse @file
          @ds[0][:warn].should include("missing-position")
          @ds[3][:warn].should == nil
      end

    end


  end
end