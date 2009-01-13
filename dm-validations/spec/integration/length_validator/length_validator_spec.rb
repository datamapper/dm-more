require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

class MotorLaunch
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :name, String, :auto_validation => false
end

class BoatDock
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :name, String, :auto_validation => false, :default => "I'm a long string"
  validates_length :name, :min => 3
end

describe DataMapper::Validate::LengthValidator do
  it "lets user specify custom error message" do
    class Jabberwock
      include DataMapper::Resource
      property :id, Integer, :key => true
      property :snickersnack, String
      validates_length :snickersnack, :within => 3..40, :message => "worble warble"
    end
    wock = Jabberwock.new
    wock.valid?.should == false
    wock.errors.on(:snickersnack).should include('worble warble')
    wock.snickersnack = "hello"
    wock.id = 1
    wock.valid?.should == true
  end

  it "lets user specify a minimum length of a string field" do
    class MotorLaunch
      validates_length :name, :min => 3
    end

    launch = MotorLaunch.new
    launch.name = 'Ab'
    launch.valid?.should == false
    launch.errors.on(:name).should include('Name must be more than 3 characters long')
  end

  it "aliases :minimum for :min" do
    class MotorLaunch
      validators.clear!
      validates_length :name, :minimum => 3
    end

    launch = MotorLaunch.new
    launch.name = 'Ab'
    launch.valid?.should == false
    launch.errors.on(:name).should include('Name must be more than 3 characters long')
  end

  it "lets user specify a maximum length of a string field" do
    class MotorLaunch
      validators.clear!
      validates_length :name, :max => 5
    end

    launch = MotorLaunch.new
    launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
    launch.valid?.should == false
    launch.errors.on(:name).should include('Name must be less than 5 characters long')
  end

  it "aliases :maximum for :max" do
    class MotorLaunch
      validators.clear!
      validates_length :name, :maximum => 5
    end
    launch = MotorLaunch.new
    launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
    launch.valid?.should == false
    launch.errors.on(:name).should include('Name must be less than 5 characters long')
  end

  it "lets user specify a length as range" do
    class MotorLaunch
      validators.clear!
      validates_length :name, :in => (3..5)
    end

    launch = MotorLaunch.new
    launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
    launch.valid?.should == false
    launch.errors.on(:name).should include('Name must be between 3 and 5 characters long')

    launch.name = 'A'
    launch.valid?.should == false
    launch.errors.on(:name).should include('Name must be between 3 and 5 characters long')

    launch.name = 'Ride'
    launch.valid?.should == true
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

  it "passes if a default fulfills the requirements" do
    doc = BoatDock.new
    doc.should be_valid
  end
end
