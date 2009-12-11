require 'spec_helper'
require 'integration/absent_field_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::Kayak' do
  before :all do
    DataMapper::Validate::Fixtures::Kayak.auto_migrate!

    @kayak = DataMapper::Validate::Fixtures::Kayak.new
    @kayak.should be_valid_for_sale
  end

  describe "with salesman being non blank" do
    before :all do
      @kayak.salesman = 'Joe'
    end

    it "is invalid" do
      @kayak.should_not be_valid_for_sale
    end

    it "has meaningful error message" do
      @kayak.errors.on(:salesman).should == [ 'Salesman must be absent' ]
    end
  end


  describe "with salesman being nil" do
    before :all do
      @kayak.salesman = nil
    end

    it "is valid" do
      @kayak.should be_valid_for_sale
    end

    it "has no error messages" do
      @kayak.errors.on(:salesman).should be_blank
    end
  end


  describe "with salesman being an empty string" do
    before :all do
      @kayak.salesman = ''
    end

    it "is valid" do
      @kayak.should be_valid_for_sale
    end

    it "has no error messages" do
      @kayak.errors.on(:salesman).should be_blank
    end
  end


  describe "with salesman being a string of white spaces" do
    before :all do
      @kayak.salesman = '    '
    end

    it "is valid" do
      @kayak.should be_valid_for_sale
    end

    it "has no error messages" do
      @kayak.errors.on(:salesman).should be_blank
    end
  end
end


describe 'DataMapper::Validate::Fixtures::Pirogue' do
  before :all do
    DataMapper::Validate::Fixtures::Pirogue.auto_migrate!

    @kayak = DataMapper::Validate::Fixtures::Pirogue.new
    @kayak.should_not be_valid_for_sale
  end

  describe "by default" do
    it "is invalid" do
      @kayak.should_not be_valid_for_sale
    end

    it "has meaningful error message" do
      @kayak.errors.on(:salesman).should == [ 'Salesman must be absent' ]
    end
  end
end
