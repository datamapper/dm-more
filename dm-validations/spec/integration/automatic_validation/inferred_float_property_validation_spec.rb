require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


{ :float => Float, :big_decimal => BigDecimal }.each do |column, type|
  describe "#{type} property" do
    before :all do
      @model = SailBoat.new(:id => 1)
    end

    describe "with an integer value" do
      before :all do
        @model.set(column => 1)
      end

      it_should_behave_like "valid model"
    end

    describe "with a float value" do
      before :all do
        @model.set(column => 1.0)
      end

      it_should_behave_like "valid model"
    end

    describe "with a BigDecimal value" do
      before :all do
        @model.set(column => BigDecimal('1'))
      end

      it_should_behave_like "valid model"
    end
  end
end
