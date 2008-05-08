require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'
  
  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::LengthValidator do
    before(:all) do
      class MotorLaunch
        include DataMapper::Resource    
        include DataMapper::Validate     
        property :name, String, :auto_validation => false   
      end
    
      class BoatDock
        include DataMapper::Resource
        include DataMapper::Validate
        property :name, String, :auto_validation => false, :default => "I'm a long string"
        validates_length_of :name, :min => 3
      end
    end

    it "should be able to set a minimum length of a string field" do
      class MotorLaunch
        validates_length_of :name, :min => 3
      end
      launch = MotorLaunch.new
      launch.name = 'Ab'
      launch.valid?.should == false
      launch.errors.full_messages.first.should == 'Name must be more than 3 characters long'
    end
  
    it "should be able to alias :minimum for :min " do
      class MotorLaunch
        validators.clear!
        validates_length_of :name, :minimum => 3
      end
      launch = MotorLaunch.new
      launch.name = 'Ab'
      launch.valid?.should == false
      launch.errors.full_messages.first.should == 'Name must be more than 3 characters long'
    end
  
    it "should be able to set a maximum length of a string field" do
      class MotorLaunch
        validators.clear!
        validates_length_of :name, :max => 5
      end
      launch = MotorLaunch.new
      launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
      launch.valid?.should == false
      launch.errors.full_messages.first.should == 'Name must be less than 5 characters long'        
    end
  
    it "should be able to alias :maximum for :max" do 
      class MotorLaunch
        validators.clear!
        validates_length_of :name, :maximum => 5
      end
      launch = MotorLaunch.new
      launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
      launch.valid?.should == false
      launch.errors.full_messages.first.should == 'Name must be less than 5 characters long'   
    end
  
    it "should be able to specify a length range of a string field" do
      class MotorLaunch
        validators.clear!
        validates_length_of :name, :in => (3..5)  
      end
      launch = MotorLaunch.new
      launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
      launch.valid?.should == false
      launch.errors.full_messages.first.should == 'Name must be between 3 and 5 characters long'      
    
      launch.name = 'A'
      launch.valid?.should == false
      launch.errors.full_messages.first.should == 'Name must be between 3 and 5 characters long'      

      launch.name = 'Ride'
      launch.valid?.should == true    
    end
  
    it "should be able to alias :within for :in" do
      class MotorLaunch
        validators.clear!
        validates_length_of :name, :within => (3..5)  
      end
      launch = MotorLaunch.new
      launch.name = 'Ride'
      launch.valid?.should == true      
    end  
  
    it "should pass if a default fufills the requirements" do
      doc = BoatDock.new
      doc.should be_valid
    end
  end

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
