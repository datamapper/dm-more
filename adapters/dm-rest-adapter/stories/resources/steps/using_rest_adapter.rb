require 'dm-core'

steps_for :using_rest_adapter do
  #To run these specs, you must have a REST Application running on port 3001 on your localhost
  #The app is expected to implement the REST API for CRUD operations on a Book

  DataMapper.setup(:default, {
    :adapter  => 'rest',
    :format => 'xml',
    :host => 'localhost',
    :port => '3001'
  })

  class Book
    include DataMapper::Resource
    property :id,         Integer, :serial => true
    property :title,      String
    property :author,     String
    property :created_at, DateTime
  end

  Given("a valid DataMapper::Resource") do
    @resource = new_book
  end

  Given("a DataMapper::Resource representing a type of Resource") do
    @type = Book
  end

  Given("the ID of an existing Resource") do
    @resource_id = 1
  end

  Given("the ID of a nonexistent Resource") do
    @resource_id = 42 ** 42
  end

  Given("a local representation of a remote Resource") do
    pending
    @resource = Book.get(1)
  end
  
  When("I try to save the Resource") do
    @result = @resource.save
  end
  
  When("I request all of the Resources of that type") do
    pending
    @resources = @type.all
  end
  
  When("I request the Resource") do
    pending
    @resource = @type.get(@resource_id)
  end

  When("I make valid changes to that Resource") do
    @resource.title = "Mary had a little lamb"
  end

  When("I make invalid changes to that Resource") do
    @resource.title = nil
  end
  
  When("I destroy the Resource") do
    pending
    @type.destroy(@resource_id)
  end
  
  Then("the Resource should save") do
    @result.should be_true
  end
  
  Then("the Resource should not save") do
    @result.should be_false
  end
  
  Then("I should not receive an empty list") do
    pending
    @resources.should_not be_empty
  end

  Then("I should receive that Resource") do
    pending
    @resource.should_not be_nil
    @reourece.id.should == @resource_id
  end

  Then("I should get nothing in return") do
    pending
    @resource.should be_nil
  end
  
  Then("the Resource will no longer be available") do
    pending
    @type.get(@resource_id).should be_nil
  end
end

def new_book(options={})
  Book.new(options.merge({:title => "Hello, World!", :author => "Anonymous"}))
end
