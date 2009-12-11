# -*- coding: utf-8 -*-
require 'spec_helper'
require 'unit/contextual_validators/spec_helper'

describe 'DataMapper::Validate::ContextualValidators' do
  before :all do
    @model = DataMapper::Validate::ContextualValidators.new
  end

  describe "initially" do
    it "is empty" do
      @model.should be_empty
    end
  end


  describe "after first reference to context" do
    before :all do
      @model.context(:create)
    end

    it "initializes list of validators for referred context" do
      @model.context(:create).should be_empty
    end
  end


  describe "after a context being added" do
    before :all do
      @model.context(:default) << DataMapper::Validate::RequiredFieldValidator.new(:toc, :when => [:publishing])
    end

    it "is no longer empty" do
      @model.should_not be_empty
    end
  end


  describe "when cleared" do
    before :all do
      @model.context(:default) << DataMapper::Validate::RequiredFieldValidator.new(:toc, :when => [:publishing])
      @model.should_not be_empty
      @model.clear!
    end

    it "becomes empty again" do
      @model.should be_empty
    end
  end
end
