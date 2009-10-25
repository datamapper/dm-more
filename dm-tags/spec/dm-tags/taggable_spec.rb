require 'spec_helper'

describe "Taggable" do
  before do
    @taggable = DefaultTaggedModel.new
  end

  it "should return an alphabetically sorted array of the tag names when sent #tag_list" do
    tag_names = %w[ tag1 tag2 tag3 ]

    # @taggable.tags = tag_names.map { |name| { :name => name } }

    tag_names.each do |name|
      @taggable.tag_taggings.new(:tag => Tag.create(:name => name))
    end

    @taggable.save.should be_true

    @taggable = @taggable.model.get!(@taggable.key)
    @taggable.tag_list.should == tag_names
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
    tag1 = Tag.create(:name => 'tag1')
    tag2 = Tag.create(:name => 'tag2')
    tag3 = Tag.create(:name => 'tag3')
    @taggable = TaggedModel.new
    @taggable.tag_list = 'tag1, tag2, tag3'
    @taggable.save.should be_true
    @taggable.tags.sort_by{|tag| tag.id}.should == [tag1, tag2, tag3]
    @taggable.tag_list = 'tag1, tag2'
    @taggable.save.should be_true # Should dirty the model when changed.
    @taggable.tags.sort_by{|tag| tag.id}.should == [tag1, tag2]
    @taggable.tag_list = 'tag3, tag4'
    @taggable.save.should be_true
    @taggable = @taggable.model.get(*@taggable.key)
    pending do
      @taggable.tags.sort_by{|tag| tag.id}.should == [tag3, Tag.first(:name => 'tag4')]
      @taggable.skills.sort_by{|skill| skill.id}.should_not == [tag3, Tag.first(:name => 'tag4')]
    end
  end

  it "should set tags with a string, and return a string (form helpers)" do
    @taggable = TaggedModel.new
    tags_string = "tag-a, tag-b, tag-c"
    @taggable.tag_collection = tags_string
    @taggable.save
    @taggable.tag_collection.should == tags_string
    @taggable.tags.size.should == 3
  end

  it "should be able to add tags and not overwrite old tags" do
    @taggable = TaggedModel.new
    @taggable.add_tag("tag-1")
    @taggable.save
    @taggable.tags.size.should == 1
    @taggable.add_tag("tag-2, tag-3")
    @taggable.save
    @taggable.tags.size.should == 3
    @taggable.add_tag("tag-4")
    @taggable.tag_list.include?("tag-4").should be_true
    @taggable.tag_list.include?("tag-1").should be_true
    @taggable.save
    @taggable.tags.size.should == 4
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

  it "should allow extra conditions for the query" do
    taggable1 = TaggedModel.new
    taggable2 = TaggedModel.new
    taggable1.tag_list = 'tag1, tag2, tag3'
    taggable2.skill_list = 'tag1, skill4'
    taggable1.save
    taggable2.save
    TaggedModel.tagged_with('tag1').should == [taggable1, taggable2]
    TaggedModel.tagged_with('tag1', :id => taggable1.id).should == [taggable1]
  end


  it "should have a class method .taggable? which returns true if tagging is defined, and false otherwise" do
    UntaggedModel.taggable?.should be_false
    TaggedModel.taggable?.should be_true
  end

  it 'should return an empty list if tag is not present (should not continue on nil tag)' do
    taggable = DefaultTaggedModel.new
    taggable.tag_list = 'tag1, tag2, tag3'
    taggable.save

    DefaultTaggedModel.tagged_with('tag5').should == []
  end

  it 'should return an empty list nothing if tag is present but not associated with model' do
    taggable1 = DefaultTaggedModel.new
    taggable1.tag_list = 'tag1, tag2, tag3'
    taggable1.save
    taggable2 = TaggedModel.new
    taggable2.tag_list = 'tag1, tag2, tag5'
    taggable2.save

    DefaultTaggedModel.tagged_with('tag5').should == []
  end

  it "should have an instance method #taggable? which returns the same as the instance's class would" do
    UntaggedModel.new.taggable?.should == UntaggedModel.taggable?
    UntaggedModel.new.taggable?.should be_false
    TaggedModel.new.taggable?.should == TaggedModel.taggable?
    TaggedModel.new.taggable?.should be_true
  end

  it 'should destroy associated taggings when destroyed' do
    taggable = TaggedModel.new
    taggable.tag_list = 'tag1, tag2, tag3'
    taggable.save
    TaggedModel.tagged_with('tag1').should == [taggable]
    taggable.destroy
    TaggedModel.tagged_with('tag1').should == []
  end

end
