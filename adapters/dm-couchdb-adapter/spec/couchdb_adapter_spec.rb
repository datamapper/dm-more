require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/couchdb_adapter'

DataMapper.setup(
  :default,
  Addressable::URI.parse("couchdb://localhost:5984/test_cdb_adapter")
)

class User
  include DataMapper::Resource

  # required for CouchDB
  property :id, String, :key => true, :field => :_id
  property :rev, String, :field => :_rev

  # regular properties
  property :name, String
  property :age, Integer
  property :wealth, Float
  property :created_at, DateTime
  property :created_on, Date
  property :location, JsonObject

  # creates methods for accessing stored/indexed views in the CouchDB database
  view :by_name, { "map" => "function(doc) { if (doc.couchdb_type == 'user') { emit(doc.name, doc); } }" }
  view :by_age,  { "map" => "function(doc) { if (doc.couchdb_type == 'user') { emit(doc.age, doc); } }" }
  view :count,   { "map" => "function(doc) { if (doc.couchdb_type == 'user') { emit(null, 1); } }",
                    "reduce" => "function(keys, values) { return sum(values); }" }

  belongs_to :company

  before :create do
    self.created_at = DateTime.now
    self.created_on = Date.today
  end
end

class Company
  include DataMapper::Resource

  # required for CouchDB
  property :id, String, :key => true, :field => :_id
  property :rev, String, :field => :_rev

  # This class happens to have similar properties
  property :name, String
  property :age, Integer

  has n, :users
end

class Person
  include DataMapper::Resource
  property :id, String, :key => true, :field => :_id
  property :rev, String, :field => :_rev
  property :type, Discriminator

  property :name, String
end

class Employee < Person
  property :rank, String
end

class Broken
  include DataMapper::Resource
  property :id, String, :key => true, :field => :_id
  property :rev, String, :field => :_rev
  property :couchdb_type, Discriminator
  property :name, String
end

describe DataMapper::Adapters::CouchdbAdapter do
  before :all do
    @adapter = DataMapper::Repository.adapters[:couchdb]
    @no_connection = false
    unless @no_connection
      begin
        @adapter.send(:http_put, "/#{@adapter.escaped_db_name}")
        DataMapper.auto_migrate!
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

  it "should create a record with a specified id" do
    pending("No CouchDB connection.") if @no_connection
    user_with_id = new_user
    user_with_id.id = 'user_id'
    user_with_id.save.should == true
    User.get!('user_id').should == user_with_id
    user_with_id.destroy
  end

  it "should get a record" do
    pending("No CouchDB connection.") if @no_connection
    created_user = new_user
    created_user.save
    user = User.get!(created_user.id)
    user.id.should_not be_nil
    user.name.should == "Jamie"
    user.age.should == 67
  end

  it "should not get records of the wrong type by id" do
    pending("No CouchDB connection.") if @no_connection
    Company.get(new_user.id).should == nil
    lambda { Company.get!(new_user.id) }.should raise_error(DataMapper::ObjectNotFoundError)
  end

  it "should update a record" do
    pending("No CouchDB connection.") if @no_connection
    created_user = new_user
    created_user.save
    user = User.get!(created_user.id)
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
    User.all.length.should == 3
  end

  it "should set total_rows on collection" do
    pending("No CouchDB connection.") if @no_connection
    User.all.total_rows.should == 3
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
    User.get!(user.id).created_at.should.eql? time
  end

  it "should handle Date" do
    pending("No CouchDB connection.") if @no_connection
    user = new_user
    user.save
    date = user.created_on
    User.get!(user.id).created_on.should == date
  end

  it "should handle JsonObject" do
    pending("No CouchDB connection.") if @no_connection
    user = new_user
    location = { 'city' => 'San Francisco', 'state' => 'California' }
    user.location = location
    user.save
    User.get!(user.id).location.should == location
  end

  it "should be able to call stored views" do
    pending("No CouchDB connection.") if @no_connection
    User.by_name.first.should == User.all(:order => [:name]).first
    User.by_age.first.should == User.all(:order => [:age]).first
  end

  it "should be able to call stored views with keys" do
    pending("No CouchDB connection.") if @no_connection
    User.by_name("Aaron").first == User.all(:name => "Aaron").first
    User.by_age(30).first == User.all(:age => 30).first
    User.by_name("Aaron").first == User.by_name(:key => "Aaron").first
    User.by_age(30).first == User.by_age(:key => 30).first
  end

  it "should return a value from a view with reduce defined" do
    pending("No CouchDB connection.") if @no_connection
    User.count.should == [ OpenStruct.new({ "value" => User.all.length, "key" => nil }) ]
  end

  describe "associations" do
    before(:all) do
      @company = Company.create(:name => "ExCorp")
      @user = User.create(:name => 'John', :company => @company)
    end
    after(:all) do
      @company.destroy
      @user.destroy
    end

    it "should work with belongs_to associations" do
      User.get(@user.id).company.should == @company
    end

    it "should work with has n associations" do
      @company.users.should include(@user)
    end
  end

  def new_user(options = {})
    default_options = { :name => "Jamie", :age => 67, :wealth => 11.5 }
    default_options.merge!(options)
    User.new(default_options)
  end

  describe 'STI' do
    it "should override default type" do
      person = Person.new(:name => 'Bob')
      person.save.should be_true
      Person.first.type.should == Person
      person.destroy.should be_true
    end

    it "should load descendents on parent.all" do
      employee = Employee.new(:name => 'Bob', :rank => 'Peon')
      employee.save.should be_true
      Person.all.include?(employee).should be_true
      employee.destroy.should be_true
    end

    it "should raise an error if you have a column named couchdb_type" do
      broken = Broken.new(:name => 'error')
      lambda { broken.save }.should raise_error(DataMapper::PersistenceError)
    end
  end
end
