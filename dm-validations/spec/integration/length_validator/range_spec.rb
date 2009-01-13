require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

# global first, then local to length validators
require __dir__.parent.parent + "spec_helper"
require __dir__ + 'spec_helper'

describe DataMapper::Validate::LengthValidator do
  it "lets user specify a length as range" do
    class MotorLaunch
      validators.clear!
      validates_length :name, :in => (3..5)
    end

    launch = MotorLaunch.new
    launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
    launch.should_not be_valid
    launch.errors.on(:name).should include('Name must be between 3 and 5 characters long')

    launch.name = 'A'
    launch.should_not be_valid
    launch.errors.on(:name).should include('Name must be between 3 and 5 characters long')

    launch.name = 'Ride'
    launch.should be_valid
  end

  it "aliases :within for :in" do
    class MotorLaunch
      validators.clear!
      validates_length :name, :within => (3..5)
    end

    launch = MotorLaunch.new
    launch.name = 'Ride'
    launch.valid?.should == true
  end  
end