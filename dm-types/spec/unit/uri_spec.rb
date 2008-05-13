require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

include DataMapper::Types

describe DataMapper::Types::URI do

  before(:each) do
    @uri_str = "http://example.com/path/to/resource/"
    @uri = Addressable::URI.parse(@uri_str)
  end

  describe ".dump" do
    it "should return the URI as a String" do
      URI.dump(@uri, :property).should == @uri_str
    end

    it "should return nil if the String is nil" do
      URI.dump(nil, :property).should be_nil
    end

    it "should return an empty URI if the String is empty" do
      URI.dump("", :property).should == ""
    end
  end

  describe ".load" do
    it "should return the URI as Addressable" do
      URI.load(@uri_str, :property).should == @uri
    end

    it "should return nil if given nil" do
      URI.load(nil, :property).should be_nil
    end

    it "should return an empty URI if given an empty String" do
      URI.load("", :property).should == Addressable::URI.parse("")
    end
  end
end
