require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::FilePath do

  before(:each) do
    @path_str = "/usr/bin/ruby"
    @path = Pathname.new(@path_str)
  end

  describe ".dump" do
    it "should return the file path as a String" do
      DataMapper::Types::FilePath.dump(@path_str, :property).should == @path_str
    end

    it "should return nil if the String is nil" do
      DataMapper::Types::FilePath.dump(nil, :property).should be_nil
    end

    it "should return an empty file path if the String is empty" do
      DataMapper::Types::FilePath.dump("", :property).should == ""
    end
  end

  describe ".load" do
    it "should return the file path as a Pathname" do
      DataMapper::Types::FilePath.load(@uri_str, :property).should == @uri
    end

    it "should return nil if given nil" do
      DataMapper::Types::FilePath.load(nil, :property).should be_nil
    end

    it "should return an empty Pathname if given an empty String" do
      DataMapper::Types::FilePath.load("", :property).should == Pathname.new("")
    end
  end
end
