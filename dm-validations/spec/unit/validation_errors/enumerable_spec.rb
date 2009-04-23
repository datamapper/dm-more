# -*- coding: utf-8 -*-
require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + '../spec_helper'

describe DataMapper::Validate::ValidationErrors do
  before :all do
    @model = DataMapper::Validate::ValidationErrors.new(Object.new)
    @model.add(:ip_address, "must have valid format")
    @model.add(:full_name, "can't be blank")
  end

  describe "#each" do
    it "iterates over properties and yields error message arrays" do
      seen = []
      @model.each do |i|
        seen << i
      end

      seen.should include(["must have valid format"])
      seen.should include(["can't be blank"])
    end
  end


  describe "#map" do
    before :all do
      @model.add(:ip_address, "must belong to a local subnet")
    end
    it "maps error message arrays using provided block" do
      projection = @model.map { |ary| ary.size }

      projection.should include(2)
      projection.should include(1)
    end
  end
end
