require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

include DataMapper::Types

describe DataMapper::Types::IPAddress do

  before(:each) do
    @ip_str = "81.20.130.1"
    @ip = IPAddr.new(@ip_str)
  end

  describe ".dump" do
    it "should return the IP address as a string" do
      IPAddress.dump(@ip, :property).should == @ip_str
    end

    it "should return nil if the string is nil" do
      IPAddress.dump(nil, :property).should be_nil
    end

    it "should return an empty IP address if the string is empty" do
      IPAddress.dump("", :property).should == ""
    end
  end

  describe ".load" do
    it "should return the IP address string as IPAddr" do
      IPAddress.load(@ip_str, :property).should == @ip
    end

    it "should return nil if given nil" do
      IPAddress.load(nil, :property).should be_nil
    end

    it "should return an empty IP address if given an empty string" do
      IPAddress.load("", :property).should == IPAddr.new("0.0.0.0")
    end
  end

end
