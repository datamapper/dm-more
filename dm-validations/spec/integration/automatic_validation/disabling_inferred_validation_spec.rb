require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

describe "A class with inferred validations disabled for all properties" do
  before :all do
    @klass = Class.new do
      include DataMapper::Resource

      property :id,   DataMapper::Types::Serial,                      :auto_validation => false
      property :name, String,                     :nullable => false, :auto_validation => false
      property :bool, DataMapper::Types::Boolean, :nullable => false, :auto_validation => false
    end
  end

  it "is valid" do
    @klass.new.valid?.should == true
  end
end