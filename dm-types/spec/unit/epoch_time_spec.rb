require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

include DataMapper::Types

describe DataMapper::Types::EpochTime do

  describe ".dump" do
    it "should accept Time objects" do
      t = Time.now

      EpochTime.dump(t, :property).should == t.to_i
    end

    it "should accept DateTime objects" do
      t = DateTime.now

      EpochTime.dump(t, :property).should == Time.parse(t.to_s).to_i
    end

    it "should accept Integer objects" do
      t = Time.now.to_i

      EpochTime.dump(t, :property).should == t
    end
  end

  describe ".load" do

    it "should load null as nil" do
      EpochTime.load(nil, :property).should == nil
    end

    it "should load #{Time.now.to_i} as Time.at(#{Time.now.to_i})" do
      t = Time.now.to_i
      EpochTime.load(Time.now.to_i, :property).should == Time.at(t)
    end
  end
end
