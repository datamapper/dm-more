require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Fixtures::TShirt do
  before :each do
    @model = DataMapper::Types::Fixtures::TShirt.new(:writing     => "Fork you",
                                                     :has_picture => true,
                                                     :picture     => :octocat,
                                                     :color       => :white,
                                                     :size        => [:xs, :medium])
  end

  describe "with multiple sizes" do
    describe "dumped and loaded" do
      before :each do
        @model.save.should be_true
        @model.reload
      end

      it "returns size as array" do
        @model.size.should == [:xs, :medium]
      end
    end
  end


  describe "with a single size" do
    before :each do
      @model.size = :large
    end

    describe "dumped and loaded" do
      before :each do
        @model.save.should be_true
        @model.reload
      end

      it "returns size as array with a single value" do
        @model.size.should == [:large]
      end
    end
  end



  # Flag does not add any auto validations
  describe "without size" do
    before :each do
      @model.should be_valid
      @model.size = nil
    end

    it "is valid" do
      @model.should be_valid
    end

    it "has no errors" do
      @model.errors.should be_blank
    end
  end
end
