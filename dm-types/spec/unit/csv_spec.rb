require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

if RUBY_VERSION >= '1.9.0'
 require 'csv'
else
  begin
    gem 'fastercsv', '~>1.4.0'
    require 'fastercsv'
    CSV = FasterCSV
  rescue LoadError
    skip_tests = true
    puts "Skipping CSV tests, please do gem install csv"
  end
end

unless skip_tests
  describe DataMapper::Types::Csv, ".load" do
    it 'should parse the value if a string is provided' do
      CSV.should_receive(:parse).with('csv_string').once
      DataMapper::Types::Csv.load('csv_string', :property)
    end

    it 'should do nothing if the value is a string' do
      CSV.should_not_receive(:parse)
      DataMapper::Types::Csv.load([], :property).should == []
    end

    it 'should return nil otherwise' do
      DataMapper::Types::Csv.load({},  :property).should == nil
      DataMapper::Types::Csv.load(nil, :property).should == nil
    end
  end

  describe DataMapper::Types::Csv, ".dump" do
    it 'should dump to CSV' do
      DataMapper::Types::Csv.dump([[1, 2, 3]], :property).should == "1,2,3\n"
    end

    it 'should do nothing if the value is a string' do
      CSV.should_not_receive(:generate)
      DataMapper::Types::Csv.dump('string', :property).should == 'string'
    end

    it 'should return nil otherwise' do
      DataMapper::Types::Csv.dump({},  :property).should == nil
      DataMapper::Types::Csv.dump(nil, :property).should == nil
    end
  end
end
