require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe Tag do
  before do
    @tag = Tag.new
  end

  it "should have id and name properties" do
    @tag.attributes.should have_key(:id)
    @tag.attributes.should have_key(:name)
  end

  it "should have many Taggings" do
    Tag.relationships.should have_key(:taggings)
  end

  it "should validate the presence of name" do
    @tag.should_not be_valid
    @tag.name = "Meme"
    @tag.should be_valid
  end

  it "should list taggables for a tag" do
    tag = Tag.create!(:name => 'tag1')
    taggable1 = TaggedModel.new
    taggable2 = TaggedModel.new
    taggable3 = TaggedModel.new
    taggable1.tag_list = "tag1"
    taggable1.save
    taggable2.tag_list = "tag1"
    taggable2.save
    tag.taggables.should == [taggable1, taggable2]
    tag.taggables.include?(taggable3).should be_false
  end
end
