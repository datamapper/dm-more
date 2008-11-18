require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

ADAPTERS.each do |adapter|

  describe 'DataMapper::Constraints' do

    before do
      DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[adapter]

      class Stable
        include DataMapper::Resource

        property :id,       Serial
        property :location, String
        property :size,     Integer

        has n, :cows
      end

      class Farmer
        include DataMapper::Resource

        property :first_name, String, :key => true
        property :last_name,  String, :key => true

        has n, :cows
      end

      class Cow
        include DataMapper::Resource
        include DataMapper::Constraints

        property :id,    Serial
        property :name,  String
        property :breed, String

        belongs_to :stable
        belongs_to :farmer
      end

      DataMapper.auto_migrate!
    end

    it "is included when DataMapper::Searchable is loaded" do
      Cow.new.should be_kind_of(DataMapper::Constraints)
    end

    it "should be able to create related objects with a foreign key constraint" do
      @s  = Stable.create(:location => "Hometown")
      @c1 = Cow.create(:name => "Bea", :stable => @s)
    end

    it "should be able to create related objects with a composite foreign key constraint" do
      @f  = Farmer.create(:first_name => "John", :last_name => "Doe")
      @c1 = Cow.create(:name => "Bea", :farmer => @f)
    end

    it "should not be able to create related objects with a failing foreign key constraint" do
      s = Stable.first(:order => [:id.desc])
      lambda { @c1 = Cow.create(:name => "Bea", :stable_id => s.id + 1) }.should raise_error
    end

  end
end
