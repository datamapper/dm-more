# -*- coding: utf-8 -*-

require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

describe DataMapper::Validate::Fixtures::Page do
  before :all do
    @model = DataMapper::Validate::Fixtures::Page.new(:id => 1024)
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
