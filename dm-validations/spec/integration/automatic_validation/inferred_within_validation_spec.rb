require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

describe 'A model with a :set & :default options on a property' do
  before :all do
    class ::LimitedBoat
      include DataMapper::Resource
      property :id,       DataMapper::Types::Serial
      property :limited,  String,   :set => ['foo', 'bar', 'bang'], :default => 'foo'
    end
  end

  describe "without value on that property" do
    before :all do
      @model = LimitedBoat.new
    end

    # default value is respected
    it_should_behave_like "valid model"
  end

  describe "without value on that property that is not in allowed range/set" do
    before :all do
      @model = LimitedBoat.new(:limited => "blah")
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:limited).should include('Limited must be one of foo, bar, bang')
    end
  end
end
