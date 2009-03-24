describe "valid model", :shared => true do
  it "is valid" do
    @model.should be_valid
  end

  it "has no error messages" do
    @model.errors.should be_empty
  end

  it "has empty list of full error messages" do
    @model.errors.full_messages.should be_empty
  end
end

describe "invalid model", :shared => true do
  it "is NOT valid" do
    @model.should_not be_valid
  end

  it "has error messages" do
    @model.errors.should_not be_blank
  end

  it "has list of full error messages" do
    @model.errors.full_messages.should_not be_blank
  end
end
