require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::AbsentFieldValidator do
    before(:all) do
      class Kayak
        include DataMapper::Resource
        include DataMapper::Validate
        property :salesman, String, :auto_validation => false

        validates_absent :salesman, :when => :sold
      end

      class Pirogue
        include DataMapper::Resource
        include DataMapper::Validate
        property :salesman, String, :default => 'Layfayette'
        validates_absent :salesman, :when => :sold
      end
    end

    it "should validate the absense of a value on an instance of a resource" do
      kayak = Kayak.new
      kayak.valid_for_sold?.should == true

      kayak.salesman = 'Joe'
      kayak.valid_for_sold?.should_not == true
    end

    it "should validate the absense of a value and ensure defaults" do
      pirogue = Pirogue.new
      pirogue.should_not be_valid_for_sold
    end

  end

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
