require 'spec_helper'

module PureRubyObjects
  # notice that it is a pure Ruby class, not a DataMapper resource
  class Country
    #
    # Behaviors
    #

    include DataMapper::Validate

    #
    # Validations
    #

    validates_present :name,       :when => [:default, :adding_to_encyclopedia]
    validates_present :population, :when => :adding_to_encyclopedia, :message => Proc.new { |record|
      "population really needs to be specified when adding %s to encyclopedia" % [record.class.name]
    }

    validates_length  :name,       :in => (4..50)

    #
    # API
    #

    attr_accessor :name, :population

    def initialize(name, population = nil)
      @name       = name
      @population = population
    end
  end
end

describe 'PureRubyObjects::Country' do
  before do
    # Powerset says so
    @model = PureRubyObjects::Country.new("Italy", 58_147_733)
  end

  describe "without name" do
    before do
      @model.name = nil
    end

    it_should_behave_like "object invalid in default context"

    it "is not valid in encyclopedia context" do
      @model.should_not be_valid(:adding_to_encyclopedia)
      @model.should_not be_valid_for_adding_to_encyclopedia
    end
  end


  describe "without name and without population information" do
    before do
      @model.name       = nil
      @model.population = nil
    end

    it_should_behave_like "object invalid in default context"

    it "is not valid in encyclopedia context" do
      @model.should_not be_valid(:adding_to_encyclopedia)
      @model.should_not be_valid_for_adding_to_encyclopedia
    end

    it "has a meaningful error message" do
      # trigger validation => have errors on the object
      @model.valid_for_adding_to_encyclopedia?
      @model.errors.on(:population).should == ["population really needs to be specified when adding PureRubyObjects::Country to encyclopedia"]
    end
  end


  describe "with name and without population information" do
    before do
      @model.population = nil
    end

    it_should_behave_like "object valid in default context"

    it "is not valid in encyclopedia context" do
      @model.should_not be_valid(:adding_to_encyclopedia)
      @model.should_not be_valid_for_adding_to_encyclopedia
    end
  end


  describe "with name and population information" do
    it_should_behave_like "object valid in default context"

    it "is valid in encyclopedia context" do
      @model.should be_valid(:adding_to_encyclopedia)
      @model.should be_valid_for_adding_to_encyclopedia
    end
  end


  describe "with a 2 characters long name" do
    before do
      @model.name = "It"
      @model.valid?
    end

    it_should_behave_like "object invalid in default context"

    it "has errors on name" do
      @model.errors.on(:name).should_not be_blank
    end

    it "is valid in encyclopedia context" do
      @model.should be_valid(:adding_to_encyclopedia)
      @model.should be_valid_for_adding_to_encyclopedia
    end
  end
end
