# -*- coding: utf-8 -*-
require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + '../spec_helper'

describe DataMapper::Validate::ValidationErrors do
  before :all do
    @model = DataMapper::Validate::ValidationErrors.new
    @model.add(:ip_address, "must have valid format")
    @model.add(:full_name, "can't be blank")
  end

  describe "#each" do
    it "iterates over properties and yields error message arrays" do
      seen = []
      @model.each do |i|
        seen << i
      end

      seen.should == [["must have valid format"], ["can't be blank"]]
    end
  end


  describe "#map" do
    before :all do
      @model.add(:ip_address, "must belong to a local subnet")
    end
    it "maps error message arrays using provided block" do
      @model.map { |ary| ary.size }.should == [2, 1]
    end
  end  
end
