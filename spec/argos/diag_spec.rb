require 'spec_helper.rb'

module Argos

  describe Diag do
  
    VALID_DIAG = File.expand_path(File.dirname(__FILE__)+"/_diag/990660_A.DIA")
  
    describe "#type" do
      it do
        Diag.new.type.should == "diag"
      end
    end
  
    describe "#parse" do
      before (:each) do
    
        @diag = Diag.new
        @diag.log = Logger.new("/dev/null")     
        @diag.parse(VALID_DIAG)
      end
      
      it "should return Argos::Diag Array" do
        @diag.filter =  lambda{|a| true}
        @diag.parse(VALID_DIAG).should be_kind_of Diag
      end
  
      describe "#size" do
        it "should == number messages" do
          @diag.size.should == File.read(VALID_DIAG).scan(/Date/i).size #448
        end
      end
  
      context "09693  Date : 29.12.99 15:36:28  LC : B  IQ : 00                               
           Lat1 : 78.324N  Lon1 :  25.384E  Lat2 : 80.326N  Lon2 :  30.049E          
           Nb mes : 002  Nb mes>-120dB : 000  Best level : -128 dB                   
           Pass duration : 062s   NOPC : 1                                           
           Calcul freq : 401 649594.3 Hz   Altitude :    0 m                         
                19032           53          352    
      " do
        it do
          @diag.parse(VALID_DIAG).select {|diag|
            diag[:measured] == "1999-12-29T15:36:28Z"
          }.first.should == { :platform=>9693, :measured=>"1999-12-29T15:36:28Z", :lc=>"B", :iq=>"00",
        :latitude=>78.324, :longitude=>25.384, :latitude2=>80.326, :longitude2=>30.049,
        :messages=>2, :messages_120dB=>0, :best_level=>-128,
        :pass_duration=>62, :nopc=>1,
        :frequency=>401649594.3, :altitude=>0,
        :sensor_data=>["19032", "53", "352"],
        :technology=>"argos",
        :type=>"diag",
        :filename=>VALID_DIAG,
        :id => "d329cfdf6ea15666159cc3bb8b84a996870c7720",
        :parser => "https://github.com/npolar/argos-ruby",
        :source =>"f53ae3ab454f3e210347439aa440c084f775f9a4"}
        end
      end
    end
    #describe '#check_format' do
    #  it 'should return true if this is a recognized Diag format' do
    #    str ="02170  Date : 03.02.09 17:47:56  LC : 3  IQ : 66 Lat1 : 33.385N  Lon1 : 111.811W  Lat2 : 35.397N  Lon2 : 121.727W Nb mes : 009  Nb mes>-120dB : 000  Best level : -126 dB Pass duration : 811s  NOPC :  3 Calcul freq : 401 637664.9 Hz   Altitude :  352 m 00           7B           5D           E0 C2           51           81           51 14           6A           30           00 3F           FC           03           00 03           FF           C0           30 00           3F           FC           0C 3F           FF           FF           C0"
    #    check_format(diag,1).should == true
    #    end
    #end  
    #  it 'should return false if there are errors in the syntax of a Diag data' do
    #    diag_with_dateformat_error ="02170  Date : 03.02.094 17:47:56  LC : 3  IQ : 66 Lat1 : 33.385N  Lon1 : 111.811W  Lat2 : 35.397N  Lon2 : 121.727W Nb mes : 009  Nb mes>-120dB : 000  Best level : -126 dB Pass duration : 811s  NOPC :  3 Calcul freq : 401 637664.9 Hz   Altitude :  352 m 00           7B           5D           E0 C2           51           81           51 14           6A           30           00 3F           FC           03           00 03           FF           C0           30 00           3F           FC           0C 3F           FF           FF           C0"
    #    res = @diag.check_format(diag_with_dateformat_error,1)
    #    res.should == false
    #  end
    #end
    
  end
end