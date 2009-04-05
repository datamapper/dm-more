require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

begin
  gem 'uuidtools', '~>1.0.7'
  require 'uuidtools'
rescue LoadError
  skip_tests = true
  puts "Skipping UUID tests, please do gem install uuidtools"
end

describe DataMapper::Types::Fixtures::NetworkNode do
  unless skip_tests
    describe "with UUID set as UUID object" do
      before :all do
        @uuid_string = 'b0fc632e-d744-4821-afe3-4ea0701859ee'
        @uuid        = UUID.parse(@uuid_string)
        @model       = DataMapper::Types::Fixtures::NetworkNode.new(:uuid => @uuid)

        @model.save.should be_true
      end

      describe "when reloaded" do
        before :all do
          @model.reload
        end

        it "has the same UUID string" do
          @model.uuid.to_s.should == @uuid_string
        end

        it "returns UUID as an object" do
          @model.uuid.should be_an_instance_of(UUID)
        end
      end
    end


    describe "with UUID set as a valid UUID string" do
      before :all do
        @uuid  = 'b0fc632e-d744-4821-afe3-4ea0701859ee'
        @model = DataMapper::Types::Fixtures::NetworkNode.new(:uuid => @uuid)
      end

      describe "when reloaded" do
        before :all do
          @model.reload
        end

        it "has the same UUID string" do
          @model.uuid.to_s.should == @uuid
        end

        it "returns UUID as an object" do
          @model.uuid.should be_an_instance_of(UUID)
        end
      end
    end


    describe "with UUID set as invalid UUID string" do
      before :all do
        @uuid  = 'meh'
        @operation = lambda do
          DataMapper::Types::Fixtures::NetworkNode.new(:uuid => @uuid)
        end
      end

      describe "when assigned UUID" do
        it "raises ArgumentError" do
          @operation.should raise_error(ArgumentError, /Invalid UUID format/)
        end
      end
    end


    describe "with UUID set as a blank string" do
      before :all do
        @uuid  = ''
        @operation = lambda do
          DataMapper::Types::Fixtures::NetworkNode.new(:uuid => @uuid)
        end
      end

      describe "when assigned UUID" do
        it "raises ArgumentError" do
          @operation.should raise_error(ArgumentError, /Invalid UUID format/)
        end
      end
    end


    describe "with missing UUID" do
      before :all do
        @uuid  = nil
        @model = DataMapper::Types::Fixtures::NetworkNode.new(:uuid => @uuid)
      end

      describe "when reloaded" do
        before :all do
          @model.reload
        end

        it "has no UUID" do
          @model.uuid.should be_nil
        end
      end
    end

  end
end
