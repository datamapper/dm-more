require 'spec_helper'

describe DataMapper::Model do

  class Widget
    include DataMapper::Resource
    property :id, Serial
    property :type, Discriminator
    property :name, String
    property :price, Integer

    belongs_to :order, :nullable => true
    validates_present :price
  end

  class Wonket < Widget
    property :size, String
  end

  class Order
    include DataMapper::Resource

    property :id, Serial

    has n, :widgets
  end

  before(:each) do
    DataMapper.auto_migrate!
    DataMapper::Sweatshop.model_map.clear
    DataMapper::Sweatshop.record_map.clear
  end

  describe ".default_fauxture_name" do
    it "is :default" do
      Order.default_fauxture_name.should == :default
    end
  end

  describe ".fixture" do
    describe "without fauxture name" do
      before :each do
        Widget.fixture {{
          :name => /\w+/.gen.capitalize,
          :price => /\d{4,5}/.gen.to_i
        }}

        @default = DataMapper::Sweatshop.model_map[Widget][:default]
      end

      it "add a fixture proc for the model with name :default" do
        @default.should_not be_empty
        @default.first.should be_kind_of(Proc)
      end
    end

    it "should allow handle complex named fixtures" do
      Wonket.fix {{
        :name => /\w+ Wonket/.gen.capitalize,
        :price => /\d{2,3}99/.gen.to_i,
        :size => %w[small medium large xl].pick
      }}

      Order.fix {{
        :widgets => (1..5).of { Widget.gen }
      }}

      Order.fix(:wonket_order) {{
        :widgets => (5..10).of { Wonket.gen }
      }}

      wonket_order = Order.gen(:wonket_order)
      wonket_order.widgets.should_not be_empty
    end

    it "should allow for STI fixtures" do
      Widget.fix {{
        :name => /\w+/.gen.capitalize,
        :price => /\d{4,5}/.gen.to_i
      }}

      Order.fix {{
        :widgets => (1..5).of { Wonket.gen }
      }}

      Order.gen.widgets.should_not be_empty
    end
  end

  describe ".make" do
    before :each do
      Widget.fix(:red) {{
        :name  => "red",
        :price => 20
      }}

      @widget = Widget.make(:red)
    end

    it "creates an object from named attributes hash" do
      @widget.name.should == "red"
      @widget.price.should == 20
    end

    it "returns a new object" do
      @widget.should be_new
    end
  end

  describe ".generate" do
    before :each do
      Widget.fix(:red) {{
        :name  => "red",
        :price => 20
      }}

      @widget = Widget.gen(:red)

      Widget.fix(:blue) {{
        :name  => "blue"
      }}
    end

    it "creates an object from named attributes hash" do
      @widget.name.should == "red"
      @widget.price.should == 20
    end

    it "returns a saved object" do
      @widget.should be_saved
    end

    it "does not save invalid model" do
      blue_widget = Widget.gen(:blue)
      blue_widget.should be_new
    end
  end

  describe ".generate!" do
    it "saves a model even if it is invalid" do
      Widget.fix(:blue) {{
        :name  => "blue"
      }}

      blue_widget = Widget.gen!(:blue)
      blue_widget.should be_saved
    end
  end

  describe ".pick" do
    before :each do
      Widget.fix(:red) {{
        :name  => "rosso",
        :price => 20
      }}

      Widget.fix(:yellow) {{
        :name  => "giallo",
        :price => 30
      }}

      Widget.fix(:blue) {{
        :name  => Proc.new { "b" + "lu" },
        :price => 40
      }}

      @red    = Widget.gen(:red)
      @yellow = Widget.gen(:yellow)
      @blue   = Widget.gen(:blue)
    end

    it "returns a pre existing object with named attributes hash" do
      @red.name.should == "rosso"
      @red.price.should == 20

      @yellow.name.should == "giallo"
      @yellow.price.should == 30
    end

    it "expands callable values of attributes hash" do
      @blue.name.should == "blu"
    end
  end

  describe ".generate_attributes" do
    before :each do
      Widget.fix(:red) {{
        :name  => "red",
        :price => 20
      }}

      @hash = Widget.generate_attributes(:red)
    end

    it "returns a Hash" do
      @hash.should be_an_instance_of(Hash)
    end

    it "returns stored attributes hash by name" do
      @hash[:name].should == "red"
      @hash[:price].should == 20
    end
  end
end
