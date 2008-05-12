require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

include DataMapper::Types

describe DataMapper::Types::Uri do
  
  before(:each) do
    @uri_str = "http://example.com/path/to/resource/"
    @uri = Addressable::URI.parse(@uri_str)
  end
  
  describe ".dump" do
    it "should return the url as string" do
      Uri.dump(@uri, :property).should == @uri_str
    end
    
    it "should return nil if string is nil" do
      Uri.dump(nil, :property).should be_nil
    end
    
    it "should return empty uri if string is empty" do
      Uri.dump("", :property).should == ""
    end
  end
  
  describe ".load" do    
    it "should return the url as Addressable" do
      Uri.load(@uri_str, :property).should == @uri
    end
    
    it "should return nil if given nil" do
      Uri.load(nil, :property).should be_nil
    end
    
    it "should return empty uri if given empty string" do
      Uri.load("", :property).should == Addressable::URI.parse("")
    end
  end
end
