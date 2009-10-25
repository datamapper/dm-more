require 'spec_helper'

include DataMapper::Tags

describe Tagging do
  before do
    @tagging = Tagging.new
    @tagged_resource = TaggedModel.create
  end

  it "should be a model which includes DataMapper::Resource" do
    Tagging.should include(DataMapper::Resource)
  end

  it "should validate the presence of tag_id, taggable_id, taggable_type and tag_context" do
    @tagging.should_not be_valid
    @tagging.tag_id = 1
    @tagging.should_not be_valid
    @tagging.taggable_id = 1
    @tagging.should_not be_valid
    @tagging.taggable_type = "TaggedModel"
    @tagging.should_not be_valid
    @tagging.tag_context = "skills"
    @tagging.should be_valid
  end

  it "should belong_to tag" do
    Tagging.relationships[:tag].should be
    Tagging.relationships[:tag].parent_model.should == Tag
  end

  it "should have a method Tagging#taggable which returns the associated taggable instance" do
    @tagging.should respond_to(:taggable)
    @tagging.taggable_id = @tagged_resource.id
    @tagging.taggable_type = @tagged_resource.model.to_s
    @tagging.taggable.should == @tagged_resource
  end
end
