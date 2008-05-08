require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'
  
  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::MethodValidator do
    before(:all) do
      class Ship
        include DataMapper::Resource    
        include DataMapper::Validate
        property :name, String
      
        validates_with_method :fail_validation, :when => [:testing_failure]
        validates_with_method :pass_validation, :when => [:testing_success]
      
        def fail_validation
          return false, 'Validation failed'
        end
      
        def pass_validation
          return true
        end    
      end
    end
  
    it "should validate via a method on the resource" do
      Ship.new().valid_for_testing_failure?().should == false
      Ship.new().valid_for_testing_success?().should == true
      ship = Ship.new()
      ship.valid_for_testing_failure?().should == false
      ship.errors.full_messages.include?('Validation failed').should == true
    end
  
  end

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
