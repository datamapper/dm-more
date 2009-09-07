require 'spec_helper'

share_examples_for 'A serialization method that also serializes core classes' do
  # This spec ensures that we don't break any serialization methods attached
  # to core classes, such as Array
  before(:all) do
    %w[ @harness ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_get(ivar)
    end

    DataMapper.auto_migrate!
  end

  before(:each) do
    Cow.all.destroy!
    Planet.all.destroy!
    FriendedPlanet.all.destroy!
  end

  it 'serializes an array of extended objects' do
    Cow.create(
      :id        => 89,
      :composite => 34,
      :name      => 'Berta',
      :breed     => 'Guernsey'
    )
    result = @harness.test(Cow.all.to_a)
    result[0].values_at("id", "composite", "name", "breed").should ==
      [89, 34, "Berta", "Guernsey"]
  end

  it 'serializes an array of collections' do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

    keys = %w[ id composite name breed ]

    resources = [
      keys.zip([  1,  2, 'Betsy', 'Jersey'   ]).to_hash,
      keys.zip([ 89, 34, 'Berta', 'Guernsey' ]).to_hash,
    ]

    collection = DataMapper::Collection.new(query, query.model.load(resources, query))

    result = @harness.test(collection)
    result[0].values_at(*keys).should == resources[0].values_at(*keys)
    result[1].values_at(*keys).should == resources[1].values_at(*keys)
  end
end

share_examples_for 'A serialization method' do
  before(:all) do
    %w[ @harness ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_get(ivar)
    end

    DataMapper.auto_migrate!
  end

  before(:each) do
    Cow.all.destroy!
    Planet.all.destroy!
    FriendedPlanet.all.destroy!
  end

  describe '(serializing single resources)' do
    it 'should serialize Model.first' do
      # At the moment this is implied by serializing a resource, but this
      # test ensures the contract even if dm-core changes
      Cow.create(
        :id        => 89,
        :composite => 34,
        :name      => 'Berta',
        :breed     => 'Guernsey'
      )
      result = @harness.test(Cow.first)
      result.values_at("name", "breed").should == ["Berta", "Guernsey"]
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

    it 'should support child associations included via the :methods parameter' do
      solar_system = SolarSystem.create(:name => "one")
      planet = Planet.new(:name => "earth")
      planet.solar_system = solar_system
      result = @harness.test(planet, :methods => [:solar_system])
      result['solar_system'].values_at('name', 'id').should == ['one', 1]
    end
  end

  describe "(collections and proxies)" do
    it 'should serialize Model.all' do
      # At the moment this is implied by serializing a collection, but this
      # test ensures the contract even if dm-core changes
      Cow.create(
        :id        => 89,
        :composite => 34,
        :name      => 'Berta',
        :breed     => 'Guernsey'
      )
      result = @harness.test(Cow.all)
      result[0].values_at("name", "breed").should == ["Berta", "Guernsey"]
    end

    it 'should serialize a collection' do
      query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

      keys = %w[ id composite name breed ]

      resources = [
        keys.zip([  1,  2, 'Betsy', 'Jersey'   ]).to_hash,
        keys.zip([ 10, 20, 'Berta', 'Guernsey' ]).to_hash,
      ]

      collection = DataMapper::Collection.new(query, query.model.load(resources, query))

      result = @harness.test(collection)
      result[0].values_at(*keys).should == resources[0].values_at(*keys)
      result[1].values_at(*keys).should == resources[1].values_at(*keys)
    end

    it 'should serialize an empty collection' do
      query = DataMapper::Query.new(DataMapper::repository(:default), Cow)
      collection = DataMapper::Collection.new(query)

      result = @harness.test(collection)
      result.should be_empty
    end

    it "serializes a one to many relationship" do
      parent = Cow.new(:id => 1, :composite => 322, :name => "Harry", :breed => "Angus")
      baby = Cow.new(:mother_cow => parent, :id => 2, :composite => 321, :name => "Felix", :breed => "Angus")

      parent.save
      baby.save

      result = @harness.test(parent.baby_cows)
      result.should be_kind_of(Array)

      result[0].values_at(*%w{id composite name breed}).should == [2, 321, "Felix", "Angus"]
    end

    it "serializes a many to one relationship" do
      parent = Cow.new(:id => 1, :composite => 322, :name => "Harry", :breed => "Angus")
      baby = Cow.new(:mother_cow => parent, :id => 2, :composite => 321, :name => "Felix", :breed => "Angus")

      parent.save
      baby.save

      result = @harness.test(baby.mother_cow)
      result.should be_kind_of(Hash)
      result.values_at(*%w{id composite name breed}).should == [1, 322, "Harry", "Angus"]
    end

    it "serializes a many to many relationship" do
      pending 'TODO: fix many to many in dm-core' do
        p1 = Planet.create(:name => 'earth')
        p2 = Planet.create(:name => 'mars')

        FriendedPlanet.create(:planet => p1, :friend_planet => p2)

        result = @harness.test(p1.reload.friend_planets)
        result.should be_kind_of(Array)

        result[0]["name"].should == "mars"
      end
    end
  end

  describe "(multiple repositories)" do
    before(:all) do
      QuanTum::Cat.auto_migrate!
      DataMapper.repository(:alternate) { QuanTum::Cat.auto_migrate! }
    end

    it "should use the repsoitory for the model" do
      gerry = QuanTum::Cat.create(:name => "gerry")
      george = DataMapper.repository(:alternate){ QuanTum::Cat.create(:name => "george", :is_dead => false) }
      @harness.test(gerry )['is_dead'].should be(nil)
      @harness.test(george)['is_dead'].should be(false)
    end
  end

  it 'should integrate with dm-validations' do
    planet = Planet.create(:name => 'a')
    results = @harness.test(planet.errors)
    results.should == {
      "name"            => planet.errors[:name],
      "solar_system_id" => planet.errors[:solar_system_id]
    }
  end
end
