require 'spec_helper'
require 'integration/required_field_validator/spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  class Holiday
    #
    # Behaviors
    #

    include DataMapper::Resource

    #
    # Properties
    #

    property :id, Serial
    property :on, Date,    :auto_validation => false

    #
    # Validations
    #

    validates_present :on
  end

  describe 'Holiday' do
    before :all do
      Holiday.auto_migrate!
    end

    before do
      @ny09 = Holiday.new(:on => Date.new(2008, 12, 31))
      @ny09.should be_valid
    end


    describe "with on = nil" do
      before do
        @ny09.on = nil
      end

      it "is NOT valid" do
        # nil = missing for Date value
        # and Holiday only has default validation context
        @ny09.should_not be_valid

        # sanity check
        @ny09.on = Date.new(2008, 12, 31)
        @ny09.should be_valid
      end
    end


    describe "with on = valid date" do
      before do
        @ny09.on = 0.0
      end

      it "IS valid" do
        # yes, presence validator does not care
        @ny09.should be_valid
      end
    end



    describe "with on = 0" do
      before do
        @ny09.on = 0
      end

      it "IS valid" do
        # yes, presence validator does not care
        @ny09.should be_valid
      end
    end



    describe "with on = 100" do
      before do
        @ny09.on = 100
      end

      it "IS valid" do
        @ny09.should be_valid
      end
    end


    describe "with on = 100.0" do
      before do
        @ny09.on = 100.0
      end

      it "IS valid" do
        @ny09.should be_valid
      end
    end


    describe "with on = -1100" do
      before do
        # presence validator does not care
        @ny09.on = -1100
      end

      it "IS valid" do
        @ny09.should be_valid
      end
    end


    describe "with on = -1100.5" do
      before do
        # presence validator does not care
        @ny09.on = -1100.5
      end

      it "IS valid" do
        @ny09.should be_valid
      end
    end
  end
end
