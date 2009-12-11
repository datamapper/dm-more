# encoding: utf-8

require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe "entity with wrong destination MAC address length", :shared => true do
  it "has error message with range bounds" do
    @model.errors.on(:destination_mac).should == [ 'Destination mac must be 6 characters long' ]
  end
end


describe 'DataMapper::Validate::Fixtures::EthernetFrame' do
  before :all do
    DataMapper::Validate::Fixtures::EthernetFrame.auto_migrate!

    @model = DataMapper::Validate::Fixtures::EthernetFrame.valid_instance
    @model.link_support_fragmentation = false
  end

  it_should_behave_like "valid model"

  describe "with destination MAC 3 'bits' long" do
    before :all do
      @model.destination_mac = "123"
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it_should_behave_like "entity with wrong destination MAC address length"
  end

  describe "with destination MAC 8 'bits' long" do
    before :all do
      @model.destination_mac = "123abce8"
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it_should_behave_like "entity with wrong destination MAC address length"
  end

  # arguable but reasonable for 80% of cases
  # to treat nil as a 0 lengh value
  # reported in
  # http://datamapper.lighthouseapp.com/projects/20609/tickets/646
  describe "that has no destination MAC address" do
    before :all do
      @model.destination_mac = nil
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it_should_behave_like "entity with wrong destination MAC address length"
  end

  describe "with a 6 'bits' destination MAC address" do
    before :all do
      @model.destination_mac = "a1b2c3"
      @model.valid?
    end

    it_should_behave_like "valid model"
  end

  describe "with multibyte characters" do
    before :all do
      @model = DataMapper::Validate::Fixtures::Currency.valid_instance(
        :name   => 'Euro',
        :code   => 'EUR',
        :symbol => '€'
      )
      @model.valid?
    end

    it_should_behave_like "valid model"
  end
end
