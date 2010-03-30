# -*- coding: utf-8 -*-

require 'spec_helper'
require 'integration/duplicated_validations/spec_helper'

describe 'DataMapper::Validations::Fixtures::Page' do
  before :all do
    DataMapper::Validations::Fixtures::Page.auto_migrate!

    @model = DataMapper::Validations::Fixtures::Page.new(:id => 1024)
  end

  describe "without body" do
    before :all do
      @model.body = nil
    end

    it_should_behave_like "invalid model"

    it "does not have duplicated error messages" do
      @model.errors.on(:body).should == ["Body must not be blank"]
    end
  end
end
