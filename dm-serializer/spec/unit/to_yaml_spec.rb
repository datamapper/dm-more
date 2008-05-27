require 'pathname'
require 'yaml'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize do

  before(:all) do
    properties = Cow.properties(:default)
    properties_with_indexes = Hash[*properties.zip((0...properties.length).to_a).flatten]
    @collection = DataMapper::Collection.new(DataMapper::repository(:default), Cow, properties_with_indexes)
    @collection.load([1, 2, 'Betsy', 'Jersey'])
    @collection.load([10, 20, 'Berta', 'Guernsey'])
  end

  #
  # ==== yummy YAML
  #

  describe "#to_yaml" do
    it "serializes single resource to YAML" do
      betsy = Cow.new
      betsy.id = 230
      betsy.composite = 22
      betsy.name = 'Betsy'
      betsy.breed = 'Jersey'
      betsy.to_yaml.gsub(/[[:space:]]+\n/, "\n").strip.should == <<-EOS.margin
      ---
      :id: 230
      :composite: 22
      :name: Betsy
      :breed: Jersey
    EOS
    end

    it "serializes a collection to YAML" do
      @collection.to_yaml.gsub(/[[:space:]]+\n/, "\n").strip.should == <<-EOS.margin
      ---
      - :id: 1
        :composite: 2
        :name: Betsy
        :breed: Jersey
      - :id: 10
        :composite: 20
        :name: Berta
        :breed: Guernsey
    EOS
    end
  end
end
