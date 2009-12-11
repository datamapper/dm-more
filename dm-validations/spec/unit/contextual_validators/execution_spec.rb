# -*- coding: utf-8 -*-
require 'spec_helper'
require 'unit/contextual_validators/spec_helper'

describe 'DataMapper::Validate::ContextualValidators' do
  before :all do
    @model = DataMapper::Validate::ContextualValidators.new
  end

  describe "#execute(name, target)" do
    before do
      @validator_one = DataMapper::Validate::RequiredFieldValidator.new(:name)
      @validator_two = DataMapper::Validate::WithinValidator.new(:operating_system, :set => ["Mac OS X", "Linux", "FreeBSD", "Solaris"])

      @model.context(:default) << @validator_one << @validator_two
    end


    describe "when target satisfies all validators" do
      before do
        @target = DataMapper::Validate::Fixtures::PieceOfSoftware.new(:name => 'gcc', :operating_system => "Mac OS X")
        @validator_one.call(@target).should be_true
        @validator_two.call(@target).should be_true

        @result = @model.execute(:default, @target)
      end

      it "returns true" do
        @result.should be_true
      end
    end


    describe "when target does not satisfy all validators" do
      before do
        @target = DataMapper::Validate::Fixtures::PieceOfSoftware.new(:name => 'Skitch', :operating_system => "Haiku")
        @validator_one.call(@target).should be_true
        @validator_two.call(@target).should be_false

        @result = @model.execute(:default, @target)
      end

      it "returns true" do
        @result.should be_false
      end
    end
  end
end
