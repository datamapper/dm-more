require 'spec_helper'
require 'integration/required_field_validator/spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  class ScheduledOperation
    #
    # Behaviors
    #

    include DataMapper::Resource

    #
    # Properties
    #

    property :id, Serial
    property :at, DateTime, :auto_validation => false

    #
    # Validations
    #

    validates_present :at
  end

  describe 'ScheduledOperation' do
    before :all do
      ScheduledOperation.auto_migrate!
    end

    before do
      @operation = ScheduledOperation.new(:at => DateTime.civil(2008, 06, 07, 15, 00, 00))
      @operation.should be_valid
    end


    describe "with on = nil" do
      before do
        @operation.at = nil
      end

      it "is NOT valid" do
        # nil = missing for Date value
        # and ScheduledOperation only has default validation context
        @operation.should_not be_valid

        # sanity check
        @operation.at = Date.new(2008, 12, 31)
        @operation.should be_valid
      end
    end


    describe "with on = valid date" do
      before do
        @operation.at = 0.0
      end

      it "IS valid" do
        # yes, presence validator does not care
        @operation.should be_valid
      end
    end



    describe "with on = 0" do
      before do
        @operation.at = 0
      end

      it "IS valid" do
        # yes, presence validator does not care
        @operation.should be_valid
      end
    end



    describe "with on = 100" do
      before do
        @operation.at = 100
      end

      it "IS valid" do
        @operation.should be_valid
      end
    end


    describe "with on = 100.0" do
      before do
        @operation.at = 100.0
      end

      it "IS valid" do
        @operation.should be_valid
      end
    end


    describe "with on = -1100" do
      before do
        # presence validator does not care
        @operation.at = -1100
      end

      it "IS valid" do
        @operation.should be_valid
      end
    end


    describe "with on = -1100.5" do
      before do
        # presence validator does not care
        @operation.at = -1100.5
      end

      it "IS valid" do
        @operation.should be_valid
      end
    end
  end
end
