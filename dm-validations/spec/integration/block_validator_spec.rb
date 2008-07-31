require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Validate::ValidatesWithBlock do
  before(:all) do
    class Ship
      include DataMapper::Resource
      property :id, Integer, :key => true
      property :name, String

      validates_with_block :when => [:testing_failure] do
        [false, 'Validation failed']
      end
      validates_with_block :when => [:testing_success] do
        true
      end
    end
  end

  it "should validate via a block on the resource" do
    Ship.new.valid_for_testing_failure?.should == false
    Ship.new.valid_for_testing_success?.should == true
    ship = Ship.new
    ship.valid_for_testing_failure?.should == false
    ship.errors.full_messages.include?('Validation failed').should == true
  end
end
