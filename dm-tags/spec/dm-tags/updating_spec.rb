require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Tag", "when updating" do
  it "should create itself" do
    o = TaggedModel.new
    o.tag_list = "abc, def, ghi"
    o.skill_list = "Casablanca, Morocco"
    o.save.should be_true
  end

  it "should update itself" do
    o = TaggedModel.first
    o.tag_list = "abc, def, xyz, jkl"
    o.skill_list = "Sahara, Morocco"
    o.save.should be_true
  end
end
