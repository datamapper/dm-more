require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + '../spec_helper'

Object.send(:remove_const, :Country) if defined?(Country)
# notice that it is a pure Ruby class, not a DataMapper resource
class ::Country
  #
  # Behaviors
  #

  include DataMapper::Validate

  #
  # Validations
  #

  validates_present :name,       :when => [:default, :adding_to_encyclopedia]
  validates_present :population, :when => :adding_to_encyclopedia

  #
  # API
  #

  attr_accessor :name, :population

  def initialize(name, population = nil)
    @name       = name
    @population = population
  end
end


describe Country do
  before :each do
    # Powerset says so
    @model = Country.new("Italy", 58_147_733)
  end

  describe "without name" do
    before :each do
      @model.name = nil
    end

    it_should_behave_like "object invalid in default context"

    it "is not valid in encyclopedia context" do
      @model.should_not be_valid(:adding_to_encyclopedia)
      @model.should_not be_valid_for_adding_to_encyclopedia
    end
  end


  describe "without name and without population information" do
    before :each do
      @model.name       = nil
      @model.population = nil
    end

    it_should_behave_like "object invalid in default context"

    it "is not valid in encyclopedia context" do
      @model.should_not be_valid(:adding_to_encyclopedia)
      @model.should_not be_valid_for_adding_to_encyclopedia
    end
  end


  describe "with name and without population information" do
    before :each do
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
end
