require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::WithinValidator do
    before(:all) do
      class Telephone
        include DataMapper::Resource
        include DataMapper::Validate
        property :type_of_number, String, :auto_validation => false
        validates_within :type_of_number, :set => ['Home','Work','Cell']
      end

      class Reciever
        include DataMapper::Resource
        include DataMapper::Validate
        property :holder, String, :auto_validation => false, :default => 'foo'
        validates_within :holder, :set => ['foo', 'bar', 'bang']
      end
    end

    it "should validate a value on an instance of a resource within a predefined set of values" do
      tel = Telephone.new
      tel.valid?.should_not == true
      tel.errors.full_messages.first.should == 'Type of number must be one of [Home, Work, Cell]'

      tel.type_of_number = 'Cell'
      tel.valid?.should == true
    end

    it "should validate a value by it's default" do
      tel = Reciever.new
      tel.should be_valid
    end
  end

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
