require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

ADAPTERS.each do |adapter|

  describe 'DataMapper::Constraints' do

    # load_models_for_metaphor :stable, :farmer, :cow

    before do
      DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[adapter]

      class Stable
        include DataMapper::Resource
        include DataMapper::Constraints

        property :id,       Serial
        property :location, String
        property :size,     Integer

        has n, :cows
      end

      class Farmer
        include DataMapper::Resource
        include DataMapper::Constraints

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
      s = Stable.create
      lambda { @c1 = Cow.create(:name => "Bea", :stable_id => s.id + 1) }.should raise_error
    end

    # :constraint associations
    # value  | on deletion of parent...
    # ---------------------------------
    # :protect | raises exception if there are child records
    # :destroy | deletes children
    # :destroy! | deletes children directly without instantiating the resource, bypassing any hooks
    # :set_nil | sets parent id to nil in child associations
    # :skip | does not do anything with children (they'll become orphan records)

    describe "constraint options" do
      describe "when no constraint options are given" do

        it "should destroy the parent if there are no children in the association" do
          @f1 = Farmer.create(:first_name => "John", :last_name => "Doe")
          @f2 = Farmer.create(:first_name => "Some", :last_name => "Body")
          @c1 = Cow.create(:name => "Bea", :farmer => @f2)
          @f1.destroy.should == true
        end

        it "should not destroy the parent if there are children in the association" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c1 = Cow.create(:name => "Bea", :farmer => @f)
          @f.destroy.should == false
        end

      end

      describe "when :constraint => :protect is given" do
        before do
          class Farmer
            has n, :cows, :constraint => :protect
          end
          class Cow
            belongs_to :farmer
          end
        end

        it "should destroy the parent if there are no children in the association" do
          @f1 = Farmer.create(:first_name => "John", :last_name => "Doe")
          @f2 = Farmer.create(:first_name => "Some", :last_name => "Body")
          @c1 = Cow.create(:name => "Bea", :farmer => @f2)
          @f1.destroy.should == true
        end

        it "should not destroy the parent if there are children in the association" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c1 = Cow.create(:name => "Bea", :farmer => @f)
          @f.destroy.should == false
        end

        it "the child should be destroyable" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c = Cow.create(:name => "Bea", :farmer => @f)
          @c.destroy.should == true
        end

      end

      describe "when :constraint => :destroy is given" do
        before do
          class Farmer
            has n, :cows, :constraint => :destroy
          end
          class Cow
            belongs_to :farmer
          end
          DataMapper.auto_migrate!
        end

        it "should destroy the parent and the children, too" do
          #NOTE: the repository wrapper is needed in order for
          # the identity map to work (otherwise @c1 in the below two calls
          # would refer to different instances)
          repository do
            @f = Farmer.create(:first_name => "John", :last_name => "Doe")
            @c1 = Cow.create(:name => "Bea", :farmer => @f)
            @c2 = Cow.create(:name => "Riksa", :farmer => @f)
            @f.destroy.should == true
            @f.should be_new_record
            @c1.should be_new_record
            @c2.should be_new_record
          end
        end

        it "the child should be destroyable" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c = Cow.create(:name => "Bea", :farmer => @f)
          @c.destroy.should == true
        end

      end

      describe "when :constraint => :set_nil is given" do
        before do
          class Farmer
            has n, :cows, :constraint => :set_nil
          end
          class Cow
            belongs_to :farmer
          end
          DataMapper.auto_migrate!
        end

        it "destroying the parent should set children foreign keys to nil" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c1 = Cow.create(:name => "Bea", :farmer => @f)
          @c2 = Cow.create(:name => "Riksa", :farmer => @f)
          cows = @f.cows
          @f.destroy.should == true
          cows.all? { |cow| cow.farmer.should be_nil }
        end

        it "the child should be destroyable" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c = Cow.create(:name => "Bea", :farmer => @f)
          @c.destroy.should == true
        end

      end # describe

      describe "when :constraint => :skip is given" do
        before do
          class Farmer
            has n, :cows, :constraint => :skip
          end
          class Cow
            belongs_to :farmer
          end
          DataMapper.auto_migrate!
        end

        it "destroying the parent should be allowed, children should become orphan records" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c1 = Cow.create(:name => "Bea", :farmer => @f)
          @c2 = Cow.create(:name => "Riksa", :farmer => @f)
          @f.destroy.should == true
          @c1.farmer.should be_new_record
          @c2.farmer.should be_new_record
        end

        it "the child should be destroyable" do
          @f = Farmer.create(:first_name => "John", :last_name => "Doe")
          @c = Cow.create(:name => "Bea", :farmer => @f)
          @c.destroy.should == true
        end

      end # describe

      describe "when an invalid option is given" do
        before do
        end

        it "should raise an error" do
          lambda do
            class Farmer
              has n, :cows, :constraint => :chocolate
            end
          end.should raise_error(ArgumentError)
        end

      end

    end # describe 'constraint options'

  end # DataMapper::Constraints
end # ADAPTERS.each
