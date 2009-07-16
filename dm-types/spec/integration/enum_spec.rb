require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Fixtures::Ticket do
  before :all do

  end

  describe "that is dumped and then loaded" do
    before :all do
      @model = DataMapper::Types::Fixtures::Ticket.new(:title  => "Can't order by aggregated fields",
                                                       :id     => 789,
                                                       :body   => "I'm trying to use the aggregate method and sort the results by a summed field, but it doesn't work.",
                                                       :status => 'confirmed')
      @model.save.should be_true
      @model.reload
    end

    it "preserves property value" do
      @model.status.should == :confirmed
    end
  end


  describe "that is supplied a matching enumeration value" do
    before :all do
      @model = DataMapper::Types::Fixtures::Ticket.new(:status => :assigned)
    end

    it "typecasts it for outside reader" do
      @model.status.should == :assigned
    end
  end


  describe "#get" do
    before :all do
      @model = DataMapper::Types::Fixtures::Ticket.new(:title  => '"sudo make install" of drizzle fails because it tries to chown mysql',
                                                       :id     => 257497,
                                                       :body   => "Note that at the very least, there should be a check to see whether or not the user is created before chown'ing a file to the user.",
                                                       :status => 'confirmed')
      @model.save.should be_true
    end

    it "supports queries with equality operator on enumeration property" do
      DataMapper::Types::Fixtures::Ticket.all(:status => :confirmed).
        should include(@model)
    end

    it "supports queries with inequality operator on enumeration property" do
      DataMapper::Types::Fixtures::Ticket.all(:status.not => :confirmed).
        should_not include(@model)
    end
  end


  describe "with value unknown to enumeration property" do
    before :all do
      @model = DataMapper::Types::Fixtures::Ticket.new(:status => :undecided)
    end

    # TODO: consider sharing shared spec exampels with dm-validations,
    #       which has 'invalid model' shared group
    it "is invalid (auto validation for :within kicks in)" do
      @model.should_not be_valid
    end

    it "has errors" do
      @model.errors.should_not be_empty
    end

    it "has a meaningful error message on invalid property" do
      @model.errors.on(:status).should include('Status must be one of unconfirmed, confirmed, assigned, resolved, not_applicable')
    end
  end
end
