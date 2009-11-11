require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe "A class with inferred validations disabled for all properties with an option" do
  before :all do
    @klass = Class.new do
      include DataMapper::Resource

      property :id,   DataMapper::Types::Serial,                      :auto_validation => false
      property :name, String,                     :required => true, :auto_validation => false
      property :bool, DataMapper::Types::Boolean, :required => true, :auto_validation => false
    end

    @model = @klass.new
  end

  describe "when instantiated w/o any attributes" do
    it_should_behave_like "valid model"
  end
end


describe "A class with inferred validations disabled for all properties with a block" do
  before :all do
    @klass = Class.new do
      include DataMapper::Resource

      without_auto_validations do
        property :id,   DataMapper::Types::Serial
        property :name, String,                     :required => true
        property :bool, DataMapper::Types::Boolean, :required => true
      end
    end

    @model = @klass.new
  end

  describe "when instantiated w/o any attributes" do
    it_should_behave_like "valid model"
  end
end
