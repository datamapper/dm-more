steps_for :read do
  Given "a Resource that returns associated resources" do
    class Shelf
      include DataMapper::Resource
      property :id,   Integer, :serial => true
      property :name, String
      has n, :books
    end
  end

  Given "the ID of an existing Resource that has associated Resources" do
    # Assuming that resource 1 is there.
    # @type.first would do a GET; that's what we're testing
    @resource_id = 1
  end

  Given "I have all of the necessary class definitions" do
    # NO-OP because defined above
  end

  When "I GET <nested resource>/<id>" do
    @resource = Shelf.get(@resource_id)
  end

  Then "I should get the Resource" do
    @resource.should_not be_nil
    @resource.should be_an_instance_of(Shelf)
    @resource.id.should == 1
  end

  Then "the Resource will have associated Resources" do
    @resource.books.should_not be_empty
    @resource.books.first.should be_an_instance_of(Book)
  end
end
