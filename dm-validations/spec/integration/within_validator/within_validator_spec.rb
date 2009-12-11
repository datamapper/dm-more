require 'spec_helper'
require 'integration/within_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::PhoneNumber' do
  before :all do
    DataMapper::Validate::Fixtures::PhoneNumber.auto_migrate!

    @model = DataMapper::Validate::Fixtures::PhoneNumber.new(:type_of_number => 'cell')
    @model.should be_valid
  end

  describe "with type of number set to 'home'" do
    before :all do
      @model.type_of_number = 'home'
    end

    it_should_behave_like "valid model"
  end


  describe "with type of number set to 'cell'" do
    before :all do
      @model.type_of_number = 'cell'
    end

    it_should_behave_like "valid model"
  end


  describe "with type of number set to 'work'" do
    before :all do
      @model.type_of_number = 'home'
    end

    it_should_behave_like "valid model"
  end


  describe "with type of number set to 'fax'" do
    before :all do
      @model.type_of_number = 'fax'
    end

    it_should_behave_like "invalid model"

    it "has meaningful error message on invalid property" do
      @model.errors.on(:type_of_number).should == [ 'Should be one of: home, cell or work' ]
    end
  end
end



describe 'DataMapper::Validate::Fixtures::MathematicalFunction' do
  before :all do
    DataMapper::Validate::Fixtures::MathematicalFunction.auto_migrate!

    @model = DataMapper::Validate::Fixtures::MathematicalFunction.new(:input => 2, :output => -2)
    @model.should be_valid
  end

  describe "with input = 0" do
    before :all do
      @model.input = 0
    end

    it_should_behave_like "invalid model"

    it "notices 'greater than or equal to 1' in the error message" do
      @model.errors.on(:input).should == [ 'Input must be greater than or equal to 1' ]
    end
  end

  describe "with input = -10" do
    before :all do
      @model.input = -10
    end

    it_should_behave_like "invalid model"

    it "notices 'greater than or equal to 1' in the error message" do
      @model.errors.on(:input).should == [ 'Input must be greater than or equal to 1' ]
    end
  end

  describe "with input = -Infinity" do
    before :all do
      @model.input = -(1.0/0)
    end

    it_should_behave_like "invalid model"

    it "notices 'greater than or equal to 1' in the error message" do
      @model.errors.on(:input).should == [ 'Input must be greater than or equal to 1' ]
    end
  end

  describe "with input = 10" do
    before :all do
      @model.input = 10
    end

    it_should_behave_like "valid model"
  end


  describe "with input = Infinity" do
    before :all do
      @model.input = (1.0/0)
    end

    it_should_behave_like "valid model"
  end


  #
  # Function range
  #

  describe "with output = 0" do
    before :all do
      @model.output = 0
    end

    it_should_behave_like "valid model"
  end

  describe "with output = -10" do
    before :all do
      @model.output = -10
    end

    it_should_behave_like "valid model"
  end

  describe "with output = -Infinity" do
    before :all do
      @model.output = -(1.0/0)
    end

    it_should_behave_like "valid model"
  end

  describe "with output = 10" do
    before :all do
      @model.output = 10
    end

    it_should_behave_like "invalid model"

    it "uses overriden error message" do
      @model.errors.on(:output).should == [ 'Negative values or zero only, please' ]
    end
  end


  describe "with output = Infinity" do
    before :all do
      @model.output = (1.0/0)
    end

    it_should_behave_like "invalid model"

    it "uses overriden error message" do
      @model.errors.on(:output).should == [ 'Negative values or zero only, please' ]
    end
  end
end
