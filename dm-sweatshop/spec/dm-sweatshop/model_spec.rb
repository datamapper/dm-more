require File.dirname(__FILE__) + '/../spec_helper'

describe DataMapper::Model do

  class Widget
    include DataMapper::Resource

    property :id, Integer, :serial => true
    property :type, Discriminator
    property :name, String
    property :price, Integer

    belongs_to :order
  end

  class Wonket < Widget
    property :size, String
  end

  class Order
    include DataMapper::Resource

    property :id, Integer, :serial => true

    has n, :widgets
  end

  before(:each) do
    DataMapper.auto_migrate!
    DataMapper::Sweatshop.model_map.clear
    DataMapper::Sweatshop.record_map.clear
  end

  describe ".fixture" do
    it "should add a fixture proc for the model" do
      Widget.fixture {{
        :name => /\w+/.gen.capitalize,
        :price => /\d{4,5}/.gen.to_i
      }}

      DataMapper::Sweatshop.model_map[Widget][:default].should_not be_empty
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
