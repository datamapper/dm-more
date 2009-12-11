require 'spec_helper'
require 'integration/confirmation_validator/spec_helper'

describe "reservation with mismatched person name", :shared => true do
  it "has meaningful error message" do
    @model.errors.on(:person_name).should == [ 'Person name does not match the confirmation' ]
  end
end

describe "reservation with mismatched seats number", :shared => true do
  it "has meaningful error message" do
    # Proc gets expanded here
    @model.errors.on(:number_of_seats).should == [ 'Reservation requires confirmation for number_of_seats' ]
  end
end


describe 'DataMapper::Validate::Fixtures::Reservation' do
  before :all do
    DataMapper::Validate::Fixtures::Reservation.auto_migrate!

    @model = DataMapper::Validate::Fixtures::Reservation.new(:person_name                  => "Tyler Durden",
                                                             :person_name_confirmation     => "Tyler Durden",
                                                             :number_of_seats              => 2,
                                                             :seats_confirmation           => 2)
    @model.should be_valid
  end

  describe "with matching person name and confirmation" do
    before :all do
      @model.person_name = "mismatch"
    end

    it_should_behave_like "invalid model"
    it_should_behave_like "reservation with mismatched person name"
  end


  describe "with a blank person name and confirmation" do
    before :all do
      @model.person_name = ""
    end

    it_should_behave_like "invalid model"
    it_should_behave_like "reservation with mismatched person name"
  end


  describe "with a missing person name and confirmation" do
    before :all do
      @model.person_name = nil
    end

    it_should_behave_like "invalid model"
    it_should_behave_like "reservation with mismatched person name"
  end


  describe "with mismatching number of seats and confirmation" do
    before :all do
      @model.number_of_seats  = -1
    end

    it_should_behave_like "invalid model"
    it_should_behave_like "reservation with mismatched seats number"
  end


  describe "with a blank number of seats and confirmation" do
    before :all do
      @model.number_of_seats = nil
    end

    it_should_behave_like "valid model"
  end
end
