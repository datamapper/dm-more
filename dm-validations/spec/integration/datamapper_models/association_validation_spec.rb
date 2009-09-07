require 'spec_helper'

describe DataMapper::Validate::Fixtures::Product do
  before :all do
    @parent = DataMapper::Validate::Fixtures::ProductCompany.create(:title => "Apple", :flagship_product => "Macintosh")
    @parent.should be_valid

    @model  = DataMapper::Validate::Fixtures::Product.new(:name => "MacBook Pro", :company => @parent)
    @model.should be_valid
  end

  describe "without company" do
    before :all do
      @model.company = nil
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:company).should == [ 'Company must not be blank' ]
    end
  end
end
