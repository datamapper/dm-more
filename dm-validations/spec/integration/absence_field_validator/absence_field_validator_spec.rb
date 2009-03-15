require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

describe DataMapper::Validate::Fixtures::Kayak do
  before :all do
    @kayak = DataMapper::Validate::Fixtures::Kayak.new
    @kayak.should be_valid_for_sale
  end

  describe "with salesman not absent" do
    before :all do
      @kayak.salesman = 'Joe'
    end

    it "is invalid" do
      @kayak.should_not be_valid_for_sale
    end

    it "has meaningful error message" do
      @kayak.errors.on(:salesman).should include('Salesman must be absent')
    end
  end
end


describe DataMapper::Validate::Fixtures::Pirogue do
  before :all do
    @kayak = DataMapper::Validate::Fixtures::Pirogue.new
    @kayak.should_not be_valid_for_sale
  end

  describe "by default" do
    it "is invalid" do
      @kayak.should_not be_valid_for_sale
    end

    it "has meaningful error message" do
      @kayak.errors.on(:salesman).should include('Salesman must be absent')
    end
  end
end
