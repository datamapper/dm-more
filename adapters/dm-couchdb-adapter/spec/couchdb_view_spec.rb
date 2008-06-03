require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/couchdb_adapter'

DataMapper.setup(
  :couchdb,
  Addressable::URI.parse("couchdb://localhost:5984/test_cdb_adapter")
)

class Zoo
  include DataMapper::Resource

  def self.default_repository_name
    :couchdb
  end

  property :id, Integer, :serial => true
  property :name, String
  property :open, TrueClass
end

describe DataMapper::View do
  it "should have a view method" do
    Zoo.should respond_to(:view)
  end

  it "should store a view when called" do
    Zoo.view :by_name
    Zoo.views.keys.should include(:by_name)
  end

  it "should initialize a new Procedure instance" do
    proc = Zoo.view :by_name_desc
    proc.should be_an_instance_of(DataMapper::View)
  end

  it "should create a getter method" do
    Zoo.view :open
    Zoo.should respond_to(:open)
  end
end

describe DataMapper::Repository do
  it "should define a view method" do
    repository(:couchdb).should respond_to(:view)
  end
end

describe DataMapper::Adapters::AbstractAdapter do
  it "should have a view method" do
    DataMapper::Adapters::AbstractAdapter.
      instance_methods.should include("view")
  end
end
