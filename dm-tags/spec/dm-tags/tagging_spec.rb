require File.dirname(__FILE__) + '/../spec_helper.rb'
include DataMapper::Tags

describe Tagging do
  before(:each) do
    @tagging = Tagging.new
  end

  it "should be a model which includes DataMapper::Resource" do
    Tagging.should be
    Tagging.should include(DataMapper::Resource)
  end

  it "should have properties: id, tag_id, taggable_id, taggable_type, tagger_id, tagger_type, and tag_context" do
    @tagging.attributes.should have_key(:id)
    @tagging.attributes.should have_key(:tag_id)
    @tagging.attributes.should have_key(:taggable_id)
    @tagging.attributes.should have_key(:taggable_type)
    # @tagging.attributes.should have_key(:tagger_id)
    # @tagging.attributes.should have_key(:tagger_type)
    @tagging.attributes.should have_key(:tag_context)
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
    @tagging.taggable.should_not be
    @tagging.taggable_id = 11111
    @tagging.taggable_type = "TaggedModel"
    TaggedModel.should_receive(:get!).with(11111)
    @tagging.taggable
  end
end
