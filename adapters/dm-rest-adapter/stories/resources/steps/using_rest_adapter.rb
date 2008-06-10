require 'dm-core'

steps_for :using_rest_adapter do
  #To run these specs, you must have a REST Application running on port 3001 on your localhost
  #The app is expected to implement the REST API for CRUD operations on a Book

  DataMapper.setup(:default, {
    :adapter  => 'rest',
    :format => 'xml',
    :base_url => 'http://localhost:3001'
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
  
  When("I try to save the Resource") do
    @result = @resource.save
  end
  
  Then("the result should indicate success") do
    @result.should be_true
  end
end

def new_book(options={})
  Book.new(options.merge({:title => "Hello, World!", :author => "Anonymous"}))
end
