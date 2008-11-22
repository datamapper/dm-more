require 'pathname'
require 'yaml'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_yaml' do
  #
  # ==== yummy YAML
  #

  before(:all) do
    @harness = Class.new(SerializerTestHarness) do
      def method_name
        :to_yaml
      end

      protected

      def deserialize(result)
        stringify_keys = lambda {|hash| hash.inject({}) {|a, (key, value)| a.update(key.to_s => value) }}
        result = YAML.load(result)
        if result.is_a?(Array)
          result.collect(&stringify_keys)
        else
          stringify_keys[result]
        end
      end
    end.new
  end

  it_should_behave_like "A serialization method"

  it "leaves out nil properties" do
    betsy = Cow.new(:id => 230, :name => "Betsy", :breed => "Jersey")
    deserialized_hash = YAML.load(betsy.to_yaml)

    deserialized_hash[:id].should        == 230
    deserialized_hash[:name].should      == "Betsy"
    deserialized_hash[:composite].should be(nil)
    deserialized_hash[:breed].should     == "Jersey"
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
