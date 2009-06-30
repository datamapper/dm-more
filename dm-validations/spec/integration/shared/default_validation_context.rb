describe "object invalid in default context", :shared => true do
  it "is not valid in default context" do
    @model.should_not be_valid
    @model.should_not be_valid(:default)
  end
end

describe "object valid in default context", :shared => true do
  it "is valid in default context" do
    @model.should be_valid
    @model.should be_valid(:default)
  end
end
