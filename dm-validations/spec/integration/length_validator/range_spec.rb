require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::EthernetFrame' do
  before :all do
    DataMapper::Validate::Fixtures::EthernetFrame.auto_migrate!

    @model = DataMapper::Validate::Fixtures::EthernetFrame.valid_instance
    @model.link_support_fragmentation = false
  end

  it_should_behave_like "valid model"

  describe "with payload that is 7 'bits' long (too short)" do
    before :all do
      @model.payload = "1234567"
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has error message with range bounds" do
      @model.errors.on(:payload).should == [ 'Payload must be between 46 and 1500 characters long' ]
    end
  end


  describe "with a one character long payload (too short)" do
    before :all do
      @model.payload = 'a'
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has error message with range bounds" do
      @model.errors.on(:payload).should == [ 'Payload must be between 46 and 1500 characters long' ]
    end
  end


  describe "with a 1600 'bits' long payload (needs fragmentation)" do
    before :all do
      @model.payload = 'a'
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has error message with range bounds" do
      @model.errors.on(:payload).should == [ 'Payload must be between 46 and 1500 characters long' ]
    end
  end


  # arguable but reasonable for 80% of cases
  # to treat nil as a 0 lengh value
  # reported in
  # http://datamapper.lighthouseapp.com/projects/20609/tickets/646
  describe "that has no payload" do
    before :all do
      @model.payload = nil
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has error message with range bounds" do
      @model.errors.on(:payload).should == [ 'Payload must be between 46 and 1500 characters long' ]
    end
  end



  describe "with a 50 characters long payload" do
    before :all do
      @model.payload = 'Imagine yourself a beautiful bag full of bits here'
      @model.valid?
    end

    it_should_behave_like "valid model"

    it "has blank error message" do
      @model.errors.on(:payload).should be_blank
    end
  end
end
