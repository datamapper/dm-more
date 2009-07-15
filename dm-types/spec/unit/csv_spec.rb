require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

if RUBY_VERSION >= '1.9.0'
 require 'csv'
else
  begin
    gem 'fastercsv', '~>1.5.0'
    require 'fastercsv'
    CSV = FasterCSV unless defined?(CSV)
  rescue LoadError
    skip_tests = true
    puts "Skipping CSV tests, please do gem install csv"
  end
end

unless skip_tests
  describe DataMapper::Types::Csv, ".load" do
    describe ".load" do
      describe "when argument is a comma separated string" do
        before :all do
          @input  = "uno,due,tre"
          @result = DataMapper::Types::Csv.load(@input, :property)
        end

        it "parses the argument using CVS parser" do
          @result.should == [["uno", "due", "tre"]]
        end
      end

      describe "when argument is an empty array" do
        before :all do
          @input    = []
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it "does not change the input" do
          @result.should == @input
        end
      end

      describe "when argument is an empty hash" do
        before :all do
          @input    = {}
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end

      describe "when argument is nil" do
        before :all do
          @input    = nil
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end

      describe "when argument is an integer" do
        before :all do
          @input    = 7
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end

      describe "when argument is a float" do
        before :all do
          @input    = 7.0
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end
    end
  end



  describe DataMapper::Types::Csv do
    describe ".dump" do
      describe "when value is a list of lists" do
        before :all do
          @input  = [["uno", "due", "tre"], ["uno", "dos", "tres"]]
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

        it "dumps value to comma separated string" do
          @result.should == "uno,due,tre\nuno,dos,tres\n"
        end
      end


      describe "when value is a string" do
        before :all do
          @input  = "beauty hides in the deep"
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

          @result.should == @input
        it "returns input as is" do
        end
      end


      describe "when value is nil" do
        before :all do
          @input  = nil
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end


      describe "when value is a hash" do
        before :all do
          @input  = { :library => "DataMapper", :language => "Ruby" }
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end
    end
  end
end
