require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/couchdb_adapter'

DataMapper.setup(
  :couchdb,
  Addressable::URI.parse("couchdb://localhost:5984/test_cdb_adapter")
)

class User
  include DataMapper::Resource

  def self.default_repository_name
    :couchdb
  end

  # required for CouchDB
  property :id, String, :key => true, :field => :_id
  property :rev, String, :field => :_rev

  # regular properties
  property :name, String
  property :age, Integer
  property :wealth, Float
  property :created_at, DateTime
  property :created_on, Date

  # creates methods for accessing stored/indexed views in the CouchDB database
  view :by_name
  view :by_age
end

class Company
  include DataMapper::Resource

  def self.default_repository_name
    :couchdb
  end

  # required for CouchDB
  property :id, String, :key => true, :field => :_id
  property :rev, String, :field => :_rev

  # This class happens to have similar properties
  property :name, String
  property :age, Integer
end

describe DataMapper::Adapters::CouchdbAdapter do
  before :all do
    @adapter = DataMapper::Repository.adapters[:couchdb]
    @no_connection = false
    unless @no_connection
      begin
        @adapter.send(:http_put, "/#{@adapter.escaped_db_name}")
        create_procedures
      rescue Errno::ECONNREFUSED
        @no_connection = true
      end
    end
  end

  after :all do
    unless @no_connection
      @adapter.send(:http_delete, "/#{@adapter.escaped_db_name}")
    end
  end

  it "should create a record" do
    pending("No CouchDB connection.") if @no_connection
    user = new_user
    user.save.should == true
    user.id.should_not == nil

    company = Company.new(:name => "IBM", :age => 119)
    company.save.should == true
    company.id.should_not == nil
  end

  it "should get a record" do
    pending("No CouchDB connection.") if @no_connection
    created_user = new_user
    created_user.save
    user = User[created_user.id]
    user.id.should_not be_nil
    user.name.should == "Jamie"
    user.age.should == 67
  end

  it "should update a record" do
    pending("No CouchDB connection.") if @no_connection
    created_user = new_user
    created_user.save
    user = User[created_user.id]
    user.name = "Janet"
    user.save
    user.name.should_not == created_user.name
    user.rev.should_not == created_user.rev
    user.age.should == created_user.age
    user.id.should == created_user.id
  end

  it "should destroy a record" do
    pending("No CouchDB connection.") if @no_connection
    created_user = new_user
    created_user.save
    created_user.destroy.should == true
  end

  it "should get all records" do
    pending("No CouchDB connection.") if @no_connection
    User.all.size.should == 3
  end

  it "should get records by eql matcher" do
    pending("No CouchDB connection.") if @no_connection
    new_user(:name => "John", :age => 50).save
    User.all(:name => "John").size.should == 1
    User.all(:age => 50).size.should == 1
    User.all(:wealth => 11.5).size.should == 4
  end

  it "should get records by not matcher" do
    pending("No CouchDB connection.") if @no_connection
    User.all(:age.not => 50).size.should == 3
  end

  it "should get records by gt matcher" do
    pending("No CouchDB connection.") if @no_connection
    User.all(:age.gt => 50).size.should == 3
  end

  it "should get records by gte matcher" do
    pending("No CouchDB connection.") if @no_connection
    User.all(:age.gte => 50).size.should == 4
  end

  it "should get records by lt matcher" do
    pending("No CouchDB connection.") if @no_connection
    User.all(:age.lt => 50).size.should == 0
  end

  it "should get records by lte matcher" do
    pending("No CouchDB connection.") if @no_connection
    User.all(:age.lte => 50).size.should == 1
  end

  it "should get records by the like matcher" do
    pending("No CouchDB connection.") if @no_connection
    User.all(:name.like => "Jo").size.should == 0
    User.all(:name.like => "Jo%").size.should == 1
    User.all(:name.like => "%J%t%").size.should == 1
    User.all(:name.like => /^Jam/).size.should == 2
  end

  it "should get records with multiple matchers" do
    pending("No CouchDB connection.") if @no_connection
    new_user(:name => "John", :age => 30).save
    User.all(:name => "John", :age.lt => 50).size.should == 1
  end

  it "should order records" do
    pending("No CouchDB connection.") if @no_connection
    new_user(:name => "Aaron", :age => 30).save
    new_user(:name => "Aaron").save
    users = User.all(:order => [:age])
    users[0].age.should == 30
    users = User.all(:order => [:name, :age])
    users[0].age.should == 30
    users[1].age.should == 67
  end

  it "should handle DateTime" do
    pending("No CouchDB connection.") if @no_connection
    user = new_user
    user.save
    time = user.created_at
    User[user.id].created_at.should == time
  end

  it "should handle Date" do
    pending("No CouchDB connection.") if @no_connection
    user = new_user
    user.save
    date = user.created_on
    User[user.id].created_on.should == date
  end

  it "should be able to call stored views" do
    pending("No CouchDB connection.") if @no_connection
    User.by_name.first.should == User.all(:order => [:name]).first
    User.by_age.first.should == User.all(:order => [:age]).first
  end

  def create_procedures
    view = Net::HTTP::Put.new("/test_cdb_adapter/_design/users")
    view["content-type"] = "text/javascript"
    view.body = {
      "language" => "text/javascript",
      "views" => {
        "by_name" =>
          "function(doc) { if (doc.type == 'user') { map(doc.name, doc); } }",
        "by_age"  =>
          "function(doc) { if (doc.type == 'user') { map(doc.age, doc); } }"
      }
    }.to_json
    @adapter.send(:request, false) do |http|
      http.request(view)
    end
  end

  def new_user(options = {})
    default_options = { :name => "Jamie", :age => 67, :wealth => 11.5 }
    default_options.merge!(options)
    User.new(default_options)
  end
end
