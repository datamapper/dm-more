require 'spec_helper'

if defined?(::CSV)
  describe DataMapper::Serialize, '#to_csv' do
    #
    # ==== blah, it's CSV
    #

    before(:all) do
      query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

      resources = [
        {:id => 1, :composite => 2, :name => 'Betsy', :breed => 'Jersey'},
        {:id => 10, :composite => 20, :name => 'Berta', :breed => 'Guernsey'}
      ]

      @collection = DataMapper::Collection.new(query, resources)

      @empty_collection = DataMapper::Collection.new(query)
    end

    it "should serialize a resource to CSV" do
      peter = Cow.new
      peter.id = 44
      peter.composite = 344
      peter.name = 'Peter'
      peter.breed = 'Long Horn'

      peter.to_csv.chomp.split(',')[0..3].should == ['44','344','Peter','Long Horn']
    end

    it "should serialize a collection to CSV" do
      result = @collection.to_csv.gsub(/[[:space:]]+\n/, "\n")
      result.split("\n")[0].split(',')[0..3].should == ['1','2','Betsy','Jersey']
      result.split("\n")[1].split(',')[0..3].should == ['10','20','Berta','Guernsey']
    end

    it 'should integration with dm-validations by providing one line per error' do
      planet = Planet.create(:name => 'a')
      result = planet.errors.to_csv.gsub(/[[:space:]]+\n/, "\n").split("\n")
      result.should include("name,#{planet.errors[:name][0]}")
      result.should include("solar_system_id,#{planet.errors[:solar_system_id][0]}")
      result.length.should == 2
    end

    describe "multiple repositories" do
      before(:all) do
        QuanTum::Cat.auto_migrate!
        DataMapper.repository(:alternate){ QuanTum::Cat.auto_migrate! }
      end

      it "should use the repsoitory for the model" do
        gerry = QuanTum::Cat.create(:name => "gerry")
        george = DataMapper.repository(:alternate){ QuanTum::Cat.create(:name => "george", :is_dead => false) }
        gerry.to_csv.should_not match(/false/)
        george.to_csv.should match(/false/)
      end
    end
  end
else
  warn "[WARNING] Cannot require 'faster_csv' or 'csv', not running #to_csv specs"
end
