require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::AcceptanceValidator do
    describe "with standard options" do
      before :all do
        class SkimBat
          include DataMapper::Resource
          property :id,        Fixnum, :serial => true
          property :sailyness, Boolean
          validates_is_accepted :sailyness
        end
        @s = SkimBat.new
      end
      it "should validate if a resource instance has accepted" do
        @s.sailyness = "1"
        @s.valid?.should == true
      end
      it "should not validate if a resource instance has not accepted" do
        @s.sailyness = "0"
        @s.valid?.should == false
      end
      it "should allow nil acceptance" do
        @s.sailyness = nil
        @s.valid?.should == true
      end
      it "should add the default message when invalid" do
        @s.sailyness = "0"
        @s.valid?.should == false
        @s.errors.full_messages.join(" ").should =~ /#{DataMapper::Validate::AcceptanceValidator.default_message_for_field("sailyness")}/
      end
    end
    describe "with :allow_nil => false" do
      before :all do
        SkimBat.class_eval do
          validators.clear!
          validates_is_accepted :sailyness, :allow_nil => false
        end
        @s = SkimBat.new
      end
      it "should not allow nil acceptance" do
        @s.sailyness = nil
        @s.valid?.should == false
      end
    end
    describe "with custom :accept" do
      before :all do
        SkimBat.class_eval do
          validators.clear!
          validates_is_accepted :sailyness, :accept => "true"
        end
        @s = SkimBat.new
      end
      it "should validate if a resource instance has accepted" do
        @s.sailyness = "true"
        @s.valid?.should == true
      end
      it "should not validate if a resource instance has not accepted" do
        @s.sailyness = "false"
        @s.valid?.should == false
      end
    end
    describe "with custom message" do
      before :all do
        SkimBat.class_eval do
          validators.clear!
          validates_is_accepted :sailyness, :message => "hehu!"
        end
        @s = SkimBat.new
      end
      it "should append the custom message when invalid" do
        @s.sailyness = "0"
        @s.valid?.should == false
        @s.errors.full_messages.join(" ").should =~ /hehu!/
      end
    end
  end

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
