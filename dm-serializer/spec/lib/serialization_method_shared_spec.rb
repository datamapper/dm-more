require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

share_examples_for 'A serialization method' do
  before do
    %w[ @harness ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_get(ivar)
    end
  end
  
  it 'should serialize a resource' do
    cow = Cow.new(
      :id        => 89,
      :composite => 34,
      :name      => 'Berta',
      :breed     => 'Guernsey'
    )
    
    result = @harness.test(cow)
    result.values_at("id", "composite", "name", "breed").should == [89,  34, 'Berta', 'Guernsey']
  end

  it 'should exclude nil properties' do
    cow = Cow.new(
      :id        => 89,
      :name      => nil
    )
    
    result = @harness.test(cow)
    result.values_at("id", "composite").should == [89,  nil]
  end

  it 'should serialize a collection' do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)
    collection = DataMapper::Collection.new(query) do |c|
      c.load([1, 2, 'Betsy', 'Jersey'])
      c.load([10, 20, 'Berta', 'Guernsey'])
    end

    result = @harness.test(collection)
    result[0].values_at("id", "composite", "name", "breed").should == [1,  2, 'Betsy', 'Jersey']
    result[1].values_at("id", "composite", "name", "breed").should == [10,  20, 'Berta', 'Guernsey']
  end

  it 'should serialize an empty collection' do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)
    collection = DataMapper::Collection.new(query) {}

    result = @harness.test(collection)
    result.should be_empty
  end

  it "should only includes properties given to :only option" do
    planet = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    )

    result = @harness.test(planet, :only => [:name])
    result.values_at("name", "aphelion").should == ["Mars", nil]
  end

  it "should serialize values returned by methods given to :methods option" do
    planet = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    )

    result = @harness.test(planet, :methods => [:category, :has_known_form_of_life?])
    # XML currently can't serialize ? at the end of method names
    boolean_method_name = @harness.method_name == :to_xml ? "has_known_form_of_life" : "has_known_form_of_life?"
    result.values_at("category", boolean_method_name).should == ["terrestrial", false]
  end

  it "should only include properties given to :only option" do
    planet = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    )

    result = @harness.test(planet, :only => [:name])
    result.values_at("name", "aphelion").should == ["Mars", nil]
  end

  it "should exclude properties given to :exclude option" do
    planet = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    )

    result = @harness.test(planet, :exclude => [:aphelion])
    result.values_at("name", "aphelion").should == ["Mars", nil]
  end

  it "should give higher precendence to :only option over :exclude" do
    planet = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    )

    result = @harness.test(planet, :only => [:name], :exclude => [:name])
    result.values_at("name", "aphelion").should == ["Mars", nil]
  end

  describe "multiple repositories" do
    before(:all) do
      QuantumCat.auto_migrate!
      repository(:alternate){QuantumCat.auto_migrate!}
    end

    it "should use the repsoitory for the model" do
      gerry = QuantumCat.create(:name => "gerry")
      george = repository(:alternate){QuantumCat.create(:name => "george", :is_dead => false)}
      @harness.test(gerry )['is_dead'].should be(nil)
      @harness.test(george)['is_dead'].should be(false)
    end
  end
end
