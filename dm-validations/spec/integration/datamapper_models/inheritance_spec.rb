require 'spec_helper'

describe 'DataMapper::Validate::Fixtures::ServiceCompany' do
  before :all do
    DataMapper::Validate::Fixtures::ServiceCompany.auto_migrate!

    @model = DataMapper::Validate::Fixtures::ServiceCompany.new(:title => "Monsters, Inc.", :area_of_expertise => "Little children's nightmares")
    @model.valid?
  end

  describe "without title" do
    before :all do
      @model.title = nil
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message for inherited property" do
      @model.errors.on(:title).should == [ 'Company name is a required field' ]
    end
  end

  describe "without area of expertise" do
    before :all do
      @model.area_of_expertise = nil
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message for own property" do
      @model.errors.on(:area_of_expertise).should == [ 'Area of expertise must not be blank' ]
    end
  end
end



describe 'DataMapper::Validate::Fixtures::ProductCompany' do
  before :all do
    DataMapper::Validate::Fixtures::ProductCompany.auto_migrate!

    @model = DataMapper::Validate::Fixtures::ProductCompany.new(:title => "Apple", :flagship_product => "Macintosh")
    @model.valid?
  end

  it_should_behave_like "valid model"

  describe "without title" do
    before :all do
      @model.title = nil
    end

    it_should_behave_like "invalid model"

    it "has error message from the subclass itself" do
      @model.errors.on(:title).should include('Product company must have a name')
    end

    # this may or may not be a desired behavior,
    # but append vs. replace is a matter of opinion
    # anyway
    #
    # TODO: there should be a way to clear validations for a field
    # that subclasses can use
    it "has error message from superclass" do
      @model.errors.on(:title).should include('Company name is a required field')
    end
  end


  describe "without flagship product" do
    before :all do
      @model.flagship_product = nil
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message for own property" do
      @model.errors.on(:flagship_product).should == [ 'Flagship product must not be blank' ]
    end
  end
end
