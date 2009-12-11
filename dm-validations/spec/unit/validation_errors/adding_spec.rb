# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'DataMapper::Validate::ValidationErrors' do
  before :all do
    @model = DataMapper::Validate::ValidationErrors.new(Object.new)
  end

  describe "after first error being added" do
    before :all do
      @model.add(:property, "can't be valid, no way")
    end

    it "is no longer empty" do
      @model.should_not be_empty
    end

    it "adds error message to list of errors for given property name" do
      @model.on(:property).should == ["can't be valid, no way"]
    end
  end


  describe "after second error being added" do
    before :all do
      @model.add(:property, "can't be valid, no way")
      @model.add(:property, "something else is wrong")
    end

    it "is no longer empty" do
      @model.should_not be_empty
    end

    it "appends error message to list of errors for given property name" do
      @model.on(:property).should == ["can't be valid, no way", "something else is wrong"]
    end
  end


  describe "when duplicate error being added" do
    before :all do
      @model.add(:property, "can't be valid, no way")
      @model.add(:property, "can't be valid, no way")
    end

    it "is no longer empty" do
      @model.should_not be_empty
    end

    it "DOES NOT allow duplication" do
      @model.on(:property).should == ["can't be valid, no way"]
    end
  end
end
