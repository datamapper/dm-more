require 'pathname'
require 'yaml'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_yaml' do
  #
  # ==== yummy YAML
  #

  before(:all) do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

    @collection = DataMapper::Collection.new(query) do |c|
      c.load([1, 2, 'Betsy', 'Jersey'])
      c.load([10, 20, 'Berta', 'Guernsey'])
    end

    @empty_collection = DataMapper::Collection.new(query) {}
    @harness = Class.new do
      def method_name
        :to_yaml
      end

      def extract_value(result, key, options = {})
        if options[:index]
          YAML.load(result)[options[:index]][key.to_sym]
        else
          YAML.load(result)[key.to_sym]
        end
      end
    end.new
  end

  it_should_behave_like "A serialization method"

  it "serializes single resource to YAML" do
    betsy = Cow.new(:id => 230, :composite => 22, :name => "Betsy", :breed => "Jersey")
    deserialized_hash = YAML.load(betsy.to_yaml)

    deserialized_hash[:id].should        == 230
    deserialized_hash[:name].should      == "Betsy"
    deserialized_hash[:composite].should == 22
    deserialized_hash[:breed].should     == "Jersey"
  end

  it "leaves out nil properties" do
    betsy = Cow.new(:id => 230, :name => "Betsy", :breed => "Jersey")
    deserialized_hash = YAML.load(betsy.to_yaml)

    deserialized_hash[:id].should        == 230
    deserialized_hash[:name].should      == "Betsy"
    deserialized_hash[:composite].should be(nil)
    deserialized_hash[:breed].should     == "Jersey"
  end

  it "handles empty collections just fine" do
    YAML.load(@empty_collection.to_yaml).should be_empty
  end

  describe "multiple repositories" do
    before(:all) do
      QuantumCat.auto_migrate!
      repository(:alternate){QuantumCat.auto_migrate!}
    end

    it "should use the repsoitory for the model" do
      gerry = QuantumCat.create(:name => "gerry")
      george = repository(:alternate){QuantumCat.create(:name => "george", :is_dead => false)}
      gerry.to_yaml.should_not match(/is_dead/)
      george.to_yaml.should match(/is_dead/)
    end
  end

end
