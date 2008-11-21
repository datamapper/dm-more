require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

share_examples_for 'A serialization method' do
  before do
    %w[ @harness ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_get(ivar)
    end
  end
  
  it 'should serialize a resource' do
    result = Cow.new(
      :id        => 89,
      :composite => 34,
      :name      => 'Berta',
      :breed     => 'Guernsey'
    ).send(@harness.method_name)
    
    @harness.extract_value(result, "id"       ).should == 89
    @harness.extract_value(result, "composite").should == 34
    @harness.extract_value(result, "name"     ).should == 'Berta'
    @harness.extract_value(result, "breed"    ).should == 'Guernsey'
  end

  it 'should serialize a collection' do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)
    collection = DataMapper::Collection.new(query) do |c|
      c.load([1, 2, 'Betsy', 'Jersey'])
      c.load([10, 20, 'Berta', 'Guernsey'])
    end

    result = collection.send(@harness.method_name)
    @harness.extract_value(result, "id",        :index => 0).should == 1
    @harness.extract_value(result, "name",      :index => 0).should == "Betsy"
    @harness.extract_value(result, "composite", :index => 0).should == 2
    @harness.extract_value(result, "breed",     :index => 0).should == "Jersey"

    @harness.extract_value(result, "id",        :index => 1).should == 10
    @harness.extract_value(result, "name",      :index => 1).should == "Berta"
    @harness.extract_value(result, "composite", :index => 1).should == 20
    @harness.extract_value(result, "breed",     :index => 1).should == "Guernsey"
  end

  it "should only includes properties given to :only option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :only => [:name])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end

  it "should serialize values returned by methods given to :methods option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :methods => [:category, :has_known_form_of_life?])
    
    @harness.extract_value(result, "category").should == "terrestrial"
    @harness.extract_value(result, "has_known_form_of_life?").should be(false)
  end

  it "should only include properties given to :only option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :only => [:name])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end

  it "should exclude properties given to :exclude option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :exclude => [:aphelion])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end

  it "should give higher precendence to :only option over :exclude" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :only => [:name], :exclude => [:name])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end
end
