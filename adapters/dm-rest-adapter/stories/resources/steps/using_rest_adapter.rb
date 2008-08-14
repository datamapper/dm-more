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

  Given("a valid DataMapper::Resource") do
    # TODO refactor
    require File.join(File.dirname(__FILE__), '..', 'helpers', 'book')
    @resource = new_book
  end

  Given("a type of Resource") do
    # TODO refactor
#    require File.join(File.dirname(__FILE__), '..', 'helpers', 'book')
#    Book = Book
  end

  Given("the ID of an existing Resource") do
    # TODO refactor
    require File.join(File.dirname(__FILE__), '..', 'helpers', 'book')
    @resource_id = Book.first.id
  end

  Given("the ID of a nonexistent Resource") do
    @resource_id = 42 ** 3
  end

  Given("a local representation of a remote Resource") do
    # TODO refactor
    require File.join(File.dirname(__FILE__), '..', 'helpers', 'book')
    @resource = Book.first
    @resource_id = @resource.id
  end

  When("I try to save the Resource") do
    @result = @resource.save
  end

  When("I request all of the Resources of that type") do
    require File.join(File.dirname(__FILE__), '..', 'helpers', 'book')
    @resources = Book.all
  end

  When("I request the Resource") do
    require File.join(File.dirname(__FILE__), '..', 'helpers', 'book')
    @resource = Book.get(@resource_id)
  end

  When("I make valid changes to that Resource") do
    @resource.title = "Mary had a little lamb"
  end

  When("I make invalid changes to that Resource") do
    @resource.title = nil
  end

  When("I destroy the Resource") do
    @resource.destroy
  end

  Then("the Resource should save") do
    @result.should be_true
  end

  Then("the Resource should not save") do
    @result.should be_false
  end

  Then("I should not receive an empty list") do
    @resources.should_not be_empty
  end

  Then("I should receive that Resource") do
    @resource.should_not be_nil
    @resource.id.should == @resource_id
  end

  Then("I should get nothing in return") do
    @resource.should be_nil
  end

  Then("the Resource will no longer be available") do
    # TODO refactor
    require File.join(File.dirname(__FILE__), '..', 'helpers', 'book')
    Book.get(@resource_id).should be_nil
  end
end

def new_book(options={})
  Book.new(options.merge({:title => "Hello, World!", :author => "Some dude"}))
end
