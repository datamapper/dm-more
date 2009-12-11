require 'spec_helper'
require 'integration/format_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::BillOfLading' do
  before :all do
    DataMapper::Validate::Fixtures::BillOfLading.auto_migrate!
  end

  def valid_attributes
    { :id => 1, :doc_no => 'A1234', :email => 'user@example.com', :url => 'http://example.com' }
  end

  describe "with doc no with value of 'BAD CODE :)'" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:doc_no => 'BAD CODE :)'))
    end

    it_should_behave_like 'invalid model'

    it "has meaningful error message on invalid field" do
      @model.errors.on(:doc_no).should == [ 'Doc no has an invalid format' ]
    end
  end

  describe "with doc no with value of 'A1234'" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:doc_no => 'A1234'))
    end

    it_should_behave_like 'valid model'
  end

  describe "with doc no with value of 'B123456X12'" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:doc_no => 'B123456X12'))
    end

    it_should_behave_like 'valid model'
  end

  describe "with missing url" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.except(:url))
    end

    it_should_behave_like 'invalid model'
  end

  describe "with blank name" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:username => ''))
    end

    it_should_behave_like 'valid model'
  end

  describe "with blank email" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:email => ''))
    end

    it_should_behave_like 'valid model'
  end
end
