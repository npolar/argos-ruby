require 'spec_helper.rb'

module Argos
  
  describe Argos do
    describe "source" do
      context "DS 990660_A.DAT" do
        ds = Ds.new
        ds.log = Logger.new("/dev/null")
        ds.parse dsfile("990660_A.DAT")
        it do
          Argos.source(ds).should ==  {:id=>"3a39e0bd0b944dca4f4fbf17bc0680704cde2994",
:technology=>"argos",
:collection=>"tracking",
:type=>"ds",
:programs=>[660, 9660],
:platforms=>[2167, 2168, 2170, 2173, 2174, 2176, 2179, 2180, 2188, 2189, 8567, 8571, 8574, 8576, 8578, 8579, 9678, 9686, 9692, 9693, 9694, 9696, 9698, 9699, 10618, 10619, 10622, 10783, 11104, 14747, 14765],
:start=>"1999-12-01T10:23:48Z",
:stop=>"1999-12-31T19:18:58Z",
:north=>79.866,
:east=>55.068,
:south=>75.822,
:west=>22.309,
:latitude_mean=>78.394,
:longitude_mean=>33.5,
:location=>"file://#{dsfile("990660_A.DAT")}",
:bytes=>107584,
:messages=>449,
:filter=>nil,
:size=>843,
:modified =>  "2013-10-21T17:02:32Z",
:parser=>Argos.library_version }
        end
      end
      context "DS 990660_A.DIA" do
        diag = Diag.new
        diag.log = Logger.new("/dev/null")
        diag.parse diagfile("990660_A.DIA")
        it do
          Argos.source(diag).should == {:id=>"f53ae3ab454f3e210347439aa440c084f775f9a4",
:technology=>"argos",
:collection=>"tracking",
:type=>"diag",
:programs=>[],
:platforms=>[2167, 2168, 2170, 2173, 2174, 2176, 2179, 2180, 2188, 2189, 8567, 8571, 8574, 8576, 8578, 8579, 9678, 9686, 9692, 9693, 9694, 9696, 9698, 9699, 10618, 10619, 10622, 10783, 11104, 14747, 14765],
:start=>"1999-12-01T10:24:54Z",
:stop=>"1999-12-31T19:18:58Z",
:north=>87.011,
:east=>65.27,
:south=>65.417,
:west=>-58.627,
:latitude_mean=>78.124,
:longitude_mean=>30.752,
:location=>"file://#{diagfile("990660_A.DIA")}",
:bytes=>222056,
:modified=>"2013-10-21T18:31:55Z",
:messages=>448,
:filter=>nil,
:size=>448,
:parser=>Argos.library_version}
        end
      end
      
    end
    
  end
end