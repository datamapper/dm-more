require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Taggable" do
  before(:each) do
    TaggedModel.all.destroy!
    AnotherTaggedModel.all.destroy!
    DefaultTaggedModel.all.destroy!
    UntaggedModel.all.destroy!
    Tag.all.destroy!
    @taggable = DefaultTaggedModel.new
  end

  it "should have an id property" do
    @taggable.attributes.should have_key(:id)
  end

  it "should return an alphabetically sorted array of the tag names when sent #tag_list" do
    tag1 = Tag.create!(:name => 'tag1')
    tag2 = Tag.create!(:name => 'tag2')
    tag3 = Tag.create!(:name => 'tag3')
    @taggable.tag_taggings << Tagging.new(:tag => tag1, :taggable_type => DefaultTaggedModel.to_s)
    @taggable.tag_taggings << Tagging.new(:tag => tag2, :taggable_type => DefaultTaggedModel.to_s)
    @taggable.tag_taggings << Tagging.new(:tag => tag3, :taggable_type => DefaultTaggedModel.to_s)
    @taggable.save.should be_true
    @taggable = DefaultTaggedModel.get!(@taggable.id)
    @taggable.tag_list.should == ['tag1', 'tag2', 'tag3']
  end

  it "should set the tag list to a sanitized, stripped, alphabetized, unique array of tag names" do
    @taggable.tag_list = "tags, !$%^&* !@more-stuff' &, tags , me_again9,  et tu   " # Must check for redundancy
    valid_array = ["et tu", "me_again9", "more-stuff", "tags"]
    @taggable.tag_list.should == valid_array
    @taggable.instance_variable_get(:@tag_list).should == valid_array
    @taggable.save
    @taggable = DefaultTaggedModel.first
    @taggable.tag_list.should == valid_array
  end

  it "should set the associated collection of tags to those whose names
      are in the tag list upon saving, creating and deleting as necessary" do
    tag1 = Tag.create!(:name => 'tag1')
    tag2 = Tag.create!(:name => 'tag2')
    tag3 = Tag.create!(:name => 'tag3')
    @taggable = TaggedModel.new
    @taggable.tag_list = 'tag1, tag2, tag3'
    @taggable.save.should be_true
    @taggable.tags.sort_by{|tag| tag.id}.should == [tag1, tag2, tag3]
    @taggable.tag_list = 'tag1, tag2'
    @taggable.save.should be_true # Should dirty the model when changed.
    @taggable.tags.sort_by{|tag| tag.id}.should == [tag1, tag2]
    @taggable.tag_list = 'tag3, tag4'
    @taggable.save.should be_true
    @taggable = TaggedModel.first
    @taggable.tags.sort_by{|tag| tag.id}.should == [tag3, Tag.first(:name => 'tag4')]
    @taggable.skills.sort_by{|skill| skill.id}.should_not == [tag3, Tag.first(:name => 'tag4')]
  end

  describe ".tagged_with" do
    it "should have a class method .tagged_with" do
      DefaultTaggedModel.should respond_to(:tagged_with)
      UntaggedModel.should_not respond_to(:tagged_with)
    end

    it "should return taggables tagged with the name given in the first argument" do
      @taggable.tag_list = 'tag1, tag2, tag3'
      @taggable.save
      taggable = DefaultTaggedModel.new
      taggable.tag_list = 'tag1, goat, fish'
      taggable.save
      DefaultTaggedModel.tagged_with('tag1').sort_by{|t| t.id}.to_a.should == [@taggable, taggable]
    end

    it "should return taggables of the context specified by the second argument" do
      taggable1 = TaggedModel.new
      taggable2 = TaggedModel.new
      taggable1.tag_list = 'tag1, tag2, tag3'
      taggable2.skill_list = 'tag1, skill4'
      taggable1.save
      taggable2.save
      TaggedModel.tagged_with('tag1').should == [taggable1, taggable2]
      TaggedModel.tagged_with('tag1', :on => 'skills').should == [taggable2]
      TaggedModel.tagged_with('tag1', :on => 'tags').should == [taggable1]
    end
  end

  it "should have a class method .taggable? which returns true if tagging is defined, and false otherwise" do
    UntaggedModel.taggable?.should be_false
    TaggedModel.taggable?.should be_true
  end

  it "should have an instance method #taggable? which returns the same as the instance's class would" do
    UntaggedModel.new.taggable?.should == UntaggedModel.taggable?
    UntaggedModel.new.taggable?.should be_false
    TaggedModel.new.taggable?.should == TaggedModel.taggable?
    TaggedModel.new.taggable?.should be_true
  end
end
