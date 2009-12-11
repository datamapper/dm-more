# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'DataMapper::Validate::ValidationErrors' do
  before :all do
    @model = DataMapper::Validate::ValidationErrors.new(Object.new)
  end

  describe "initially" do
    it "is empty" do
      @model.should be_empty
    end
  end

  # Not sure if this is worth having at all,
  # just keeping old spec suite bits in place
  # if they make no harm — MK
  describe "after enquiry" do
    before :all do
      @model.on(:property)
    end

    it "is still empty" do
      @model.should be_empty
    end
  end


  describe "after errors being added" do
    before :all do
      @model.add(:property, "can't be valid, no way")
    end

    it "is no longer empty" do
      @model.should_not be_empty
    end
  end
end
