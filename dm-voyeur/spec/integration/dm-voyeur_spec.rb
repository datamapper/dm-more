require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Voyeur do
  before :all do
    class Adam
      include DataMapper::Resource
      
      property :id, Integer, :serial => true
      property :name, String
      attr_accessor :done
      
      def falling?
        @falling
      end
      
      def dig_a_hole_to_china
        @done = true
      end
      
      def drink
        @happy = true
      end
      
      def happy?
        @happy
      end
      
    end
    Adam.auto_migrate!
    
    class Beer
      include DataMapper::Resource
      
      property :id, Integer, :serial => true
      property :name, String
      
      def drink
        @empty = true
      end
      
      def empty?
        @empty
      end
      
    end
    Beer.auto_migrate!
    
    class AdamVoyeur
      include DataMapper::Voyeur
      
      peep :adam
      
      before :save do
        @falling = true
      end
      
      before :dig_a_hole_to_china do
        throw :halt
      end
      
    end
    
    class DrinkingVoyeur
      include DataMapper::Voyeur
      
      peep :adam, :beer
      
      after :drink do
        @refrigerated = true
      end
      
    end
    
  end
    
  before(:each) do
    @adam = Adam.new
    @beer = Beer.new
  end
  
  it "should assign a callback" do
    @adam.should_not be_falling
    @adam.name = "Adam French"
    @adam.save
    @adam.should be_falling
  end    
  
  it "should be able to trigger an abort" do
     @adam.dig_a_hole_to_china
     @adam.done.should be_nil
  end
  
  it "peep should add a class to the neighborhood watch" do
    AdamVoyeur.should have(1).neighborhood_watch
    AdamVoyeur.neighborhood_watch.first.should == Adam
  end
  
  it "peep should add more than one class to the neighborhood watch" do
    DrinkingVoyeur.should have(2).neighborhood_watch
    DrinkingVoyeur.neighborhood_watch.first.should == Adam
    DrinkingVoyeur.neighborhood_watch[1].should == Beer
  end
  
  it "should peep multiple classes with the same method name" do
    @adam.should_not be_happy
    @beer.should_not be_empty
    @adam.drink
    @beer.drink
    @adam.should be_happy
    @beer.should be_empty
  end
  
end