require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + '../spec_helper'

Object.send(:remove_const, :Yacht) if defined?(Yacht)
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
    @country = Country.new("Italy", 58_147_733)
  end

  describe "without name" do
    before :each do
      @country.name = nil
    end

    it "is not valid in default context" do
      @country.should_not be_valid
      @country.should_not be_valid(:default)
    end

    it "is not valid in encyclopedia context" do
      @country.should_not be_valid(:adding_to_encyclopedia)
      @country.should_not be_valid_for_adding_to_encyclopedia
    end
  end


  describe "without name and without population information" do
    before :each do
      @country.name       = nil
      @country.population = nil
    end

    it "is not valid in default context" do
      @country.should_not be_valid
      @country.should_not be_valid(:default)
    end

    it "is not valid in encyclopedia context" do
      @country.should_not be_valid(:adding_to_encyclopedia)
      @country.should_not be_valid_for_adding_to_encyclopedia
    end
  end  

  
  describe "with name and without population information" do
    before :each do
      @country.population = nil
    end

    it "is valid in default context" do
      @country.should be_valid
      @country.should be_valid(:default)
    end

    it "is not valid in encyclopedia context" do
      @country.should_not be_valid(:adding_to_encyclopedia)
      @country.should_not be_valid_for_adding_to_encyclopedia
    end
  end


  describe "with name and population information" do
    it "is valid in default context" do
      @country.should be_valid
      @country.should be_valid(:default)
    end

    it "is valid in encyclopedia context" do
      @country.should be_valid(:adding_to_encyclopedia)
      @country.should be_valid_for_adding_to_encyclopedia
    end
  end  
end
