require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::RequiredFieldValidator do
    after do
      repository(:sqlite3).adapter.execute('DROP TABLE "landscapers"');
      repository(:sqlite3).adapter.execute('DROP TABLE "gardens"');
    end

    before do
      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        CREATE TABLE "landscapers" (
          "id" INTEGER PRIMARY KEY,
          "name" VARCHAR(50)
        )
      EOS
      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        CREATE TABLE "gardens" (
          "id" INTEGER PRIMARY KEY,
          "landscaper_id" INTEGER,
          "name" VARCHAR(50)
        )
      EOS

      class Landscaper
        include DataMapper::Resource
        property :id, Fixnum, :key => true
        property :name, String
      end

      class Garden
        include DataMapper::Resource
        property :id, Fixnum, :key => true
        property :landscaper_id, Fixnum
        property :name, String, :auto_validation => false

        belongs_to :landscaper #has :landscaper, 1..n

        validates_present :name, :when => :property_test
        validates_present :landscaper, :when => :association_test
      end

      class Fertilizer
        include DataMapper::Resource
        property :id, Fixnum, :serial => true
        property :brand, String, :auto_validation => false, :default => 'Scotts'
        validates_present :brand, :when => :property_test
      end
    end

    it "should validate the presence of a property value on an instance of a resource" do
      garden = Garden.new
      garden.should_not be_valid_for_property_test
      garden.errors.on(:name).should include('Name must not be blank')

      garden.name = 'The Wilds'
      garden.should be_valid_for_property_test
    end

    it "should validate the presence of an association value on an instance of a resource when dirty"
    #do
    #  garden = Garden.new
    #  landscaper = garden.landscaper
    #  puts landscaper.children.length
    #  #puts "Gardens landscaper is #{garden.landscaper.child_key}"
    #end

    it "should pass when a default is available" do
      fert = Fertilizer.new
      fert.should be_valid_for_property_test
    end
  end

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
