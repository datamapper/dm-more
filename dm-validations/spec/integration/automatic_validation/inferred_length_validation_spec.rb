require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe 'SailBoat' do
  before :all do
    SailBoat.auto_migrate!

    @model      = SailBoat.new(:id => 1)
    @model.should be_valid_for_length_test_1
  end


  describe "with a nil value on property that allows nil" do
    before :all do
      @model.allow_nil = nil
    end

    it "is valid" do
      @model.should be_valid_for_nil_test
    end
  end


  describe "with 11 characters long description" do
    before :all do
      @model.description = 'ABCDEFGHIJK' #11
    end

    # validates_length is inferred from property's :length option
    it "is invalid" do
      @model.should_not be_valid_for_length_test_1
      @model.errors.on(:description).should == [ 'Description must be at most 10 characters long' ]
    end
  end


  describe "with 9 characters long description" do
    before :all do
      @model.description = 'ABCDEFGHI' # 9
    end

    # validates_length is inferred from property's :length option
    it_should_behave_like "valid model"
  end

  describe "with 2 character long note" do
    before :all do
      @model = SailBoat.new(:notes => "AB")
    end

    it "is valid" do
      @model.should be_valid_for_length_test_2
    end
  end

  describe "with 10 character long note" do
    before :all do
      @model = SailBoat.new(:notes => "ABCDEFGHIJ")
    end

    it "is valid" do
      @model.should be_valid_for_length_test_2
    end
  end

  describe "with 11 character long note" do
    before :all do
      @model = SailBoat.new(:notes => "ABCDEFGHIJK")
    end

    it "is invalid" do
      @model.should_not be_valid_for_length_test_2
    end

    it "has a meaningful error message" do
      @model.errors.on(:notes).should  == [ 'Notes must be between 2 and 10 characters long' ]
    end
  end
end



describe 'DataMapper::Validate::Fixtures::SmsMessage' do
  before :all do
    DataMapper::Validate::Fixtures::SmsMessage.auto_migrate!

    @model = DataMapper::Validate::Fixtures::SmsMessage.new(:id => 10)
  end

  describe "with 2 character long note" do
    before :all do
      @model.body = "ab"
    end

    it_should_behave_like "valid model"
  end

  describe "with 10 character long note" do
    before :all do
      @model.body = "ABCDEFGHIJ"
    end

    it_should_behave_like "valid model"
  end

  describe "with 499 character long note" do
    before :all do
      @model.body = "a" * 499
    end

    it_should_behave_like "valid model"
  end

  describe "with 503 character long note" do
    before :all do
      @model.body = "a" * 503
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:body).should == [ 'Body must be between 1 and 500 characters long' ]
    end
  end
end
