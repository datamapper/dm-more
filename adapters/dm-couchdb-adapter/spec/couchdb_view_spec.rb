require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class Viewable
  include DataMapper::CouchResource

  property :name, String
  property :open, TrueClass
end

describe DataMapper::CouchResource::View do
  it "should have a view method" do
    Viewable.should respond_to(:view)
  end

  it "should store a view when called" do
    Viewable.view :by_name
    Viewable.views.keys.should include(:by_name)
  end

  it "should initialize a new Procedure instance" do
    proc = Viewable.view :by_name_desc
    proc.should be_an_instance_of(DataMapper::CouchResource::View)
  end

  it "should create a getter method" do
    Viewable.view :open
    Viewable.should respond_to(:open)
  end
end
