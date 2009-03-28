require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + '../spec_helper'


describe DataMapper::Validate::Fixtures::ServiceCompany do
  before :all do
    @model = DataMapper::Validate::Fixtures::ServiceCompany.new
  end

  it_should_behave_like "invalid model"

  it "has a meaningful error message" do
    @model.errors.on(:title).should include("Company name is a required field")
  end
end
