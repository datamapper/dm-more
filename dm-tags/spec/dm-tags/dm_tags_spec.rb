require 'spec_helper'

describe DataMapper::Tags do
  it "should add a .has_tags method to models which include DataMapper::Resource" do
    TaggedModel.should respond_to(:has_tags)
    AnotherTaggedModel.should respond_to(:has_tags)
    DefaultTaggedModel.should respond_to(:has_tags)
    UntaggedModel.should respond_to(:has_tags)
  end

  it "should add a .has_tags_on method to models which include DataMapper::Resource" do
    TaggedModel.should respond_to(:has_tags_on)
    AnotherTaggedModel.should respond_to(:has_tags_on)
    DefaultTaggedModel.should respond_to(:has_tags_on)
    UntaggedModel.should respond_to(:has_tags_on)
  end

  describe ".has_tags_on" do
    it "should accept an array of context names" do
      Object.send(:remove_const, :HasTagsOnTestModel) if defined?(HasTagsOnTestModel)
      class ::HasTagsOnTestModel
        include DataMapper::Resource
        property :id, Serial
      end
      lambda{HasTagsOnTestModel.has_tags_on(:should, 'not', :raise)}.should_not raise_error(ArgumentError)
    end

    it "should create taggable functionality for each of the context names passed" do
      Object.send(:remove_const, :TestModel) if defined?(TestModel)
      class ::TestModel
        include DataMapper::Resource
        property :id, Serial

        has_tags_on(:pets, 'skills', :tags)
      end
      TestModel.should be_taggable
      a = TestModel.new
      a.should be_taggable
      a.should respond_to(:pet_list)
      a.should respond_to(:skill_list)
      a.should respond_to(:tag_list)
      a.should respond_to(:pet_list=)
      a.should respond_to(:skill_list=)
      a.should respond_to(:tag_list=)
    end
  end

  describe ".has_tags" do
    it "should create a taggable with 'tags' context regardless of passed arguments" do
      Object.send(:remove_const, :TagsOnly) if defined?(TagsOnly)
      class ::TagsOnly
        include DataMapper::Resource
        property :id, Serial
        has_tags :pets, :skills
      end
      TagsOnly.should be_taggable
      TagsOnly.new.should be_taggable
      a = TagsOnly.new
      a.should respond_to(:tag_list)
      a.should respond_to(:tag_list=)
      a.should respond_to(:tags)
      a.should_not respond_to(:pet_list)
      a.should_not respond_to(:pet_list=)
      a.should_not respond_to(:pets)
      a.should_not respond_to(:skill_list)
      a.should_not respond_to(:skill_list=)
      a.should_not respond_to(:skills)
    end
  end
end
