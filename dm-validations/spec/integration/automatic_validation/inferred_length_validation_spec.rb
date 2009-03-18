require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'



describe SailBoat do
  before :all do
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
      @model.errors.on(:description).should include('Description must be less than 10 characters long')
    end
  end


  describe "with 9 characters long description" do
    before :all do
      @model.description = 'ABCDEFGHI' # 9
    end

    # validates_length is inferred from property's :length option
    it_should_behave_like "valid model"
  end

  it "should auto add validates_length within a range when option :length
      or :size is a range" do
    # Range test notes = 2..10
    boat = SailBoat.new
    boat.should be_valid_for_length_test_2
    boat.notes = 'AB' #2
    boat.should be_valid_for_length_test_2
    boat.notes = 'ABCDEFGHIJK' #11
    boat.should_not be_valid_for_length_test_2
    boat.errors.on(:notes).should include('Notes must be between 2 and 10 characters long')
    boat.notes = 'ABCDEFGHIJ' #10
    boat.should be_valid_for_length_test_2
  end

  it "should auto validate all strings for max length" do
    klass = Class.new do
      include DataMapper::Resource
      property :id, DataMapper::Types::Serial
      property :name, String
    end
    t = klass.new(:id => 1)
    t.should be_valid
    t.name = 'a' * 51
    t.should_not be_valid
    t.errors.on(:name).should include('Name must be less than 50 characters long')
  end
end