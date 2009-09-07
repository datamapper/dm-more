require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe SailBoat do
  before :all do
    @model      = SailBoat.new(:id => 1)
    @model.name = 'Float'
    @model.should be_valid_for_presence_test
  end

  describe "without name" do
    before :all do
      @model.name = nil
    end

    # has validates_is_present for name thanks to :nullable => false
    it "is invalid" do
      @model.should_not be_valid_for_presence_test
      @model.errors.on(:name).should == [ 'Name must not be blank' ]
    end
  end
end



describe SailBoat do
  before :all do
    @model      = SailBoat.new(:id => 1)
    @model.name = 'Float'
    @model.should be_valid_for_presence_test
  end

  describe "with a name" do
    before :all do
      # no op
    end

    # has validates_is_present for name thanks to :nullable => false
    it_should_behave_like "valid model"
  end
end
