require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe 'Inferred validations' do
  it "allow overriding a single error message" do
    custom_boat = Class.new do
      include DataMapper::Resource
      property :id,   DataMapper::Types::Serial
      property :name, String,  :required => true, :message => "This boat must have name"
    end
    boat = custom_boat.new
    boat.should_not be_valid
    boat.errors.on(:name).should == [ 'This boat must have name' ]
  end

  it "should have correct error messages" do
    custom_boat = Class.new do
      include DataMapper::Resource
      property :id,   DataMapper::Types::Serial
      property :name, String,  :required => true, :length => 5..20, :format => /^[a-z]+$/,
               :messages => {
                 :presence => "This boat must have name",
                 :length => "Name must have at least 4 and at most 20 chars",
                 :format => "Please use only small letters"
               }
    end

    boat = custom_boat.new
    boat.should_not be_valid
    boat.errors.on(:name).should == [ 'This boat must have name' ]

    boat.name = "%%"
    boat.should_not be_valid
    boat.errors.on(:name).should == [
      'Name must have at least 4 and at most 20 chars',
      'Please use only small letters',
    ]

    boat.name = "%%asd"
    boat.should_not be_valid
    boat.errors.on(:name).should == [ 'Please use only small letters' ]

    boat.name = "superboat"
    boat.should be_valid
    boat.errors.on(:name).should be_nil
  end
end
