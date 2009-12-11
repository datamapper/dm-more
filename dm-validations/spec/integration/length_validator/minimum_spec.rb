require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe "entity with a name shorter than 2 characters", :shared => true do
  it "has a meaninful error message with length restrictions mentioned" do
    @model.errors.on(:name).should == [ 'Name must be at least 2 characters long' ]
  end
end

describe 'DataMapper::Validate::Fixtures::Mittelschnauzer' do
  before :all do
    DataMapper::Validate::Fixtures::Mittelschnauzer.auto_migrate!

    @model = DataMapper::Validate::Fixtures::Mittelschnauzer.valid_instance
  end

  it_should_behave_like "valid model"

  describe "with a 13 characters long name" do
    it_should_behave_like "valid model"
  end

  describe "with a single character name" do
    before :all do
      @model.name = "R"
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it_should_behave_like "entity with a name shorter than 2 characters"
  end

  describe "with blank name" do
    before :all do
      @model.name = ""
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it_should_behave_like "entity with a name shorter than 2 characters"
  end
end
