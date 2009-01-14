require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  # keep in mind any ScmOperation has a default value for brand property
  # so it is used
  describe GitOperation do
    before :each do
      @operation = GitOperation.new(:network_connection => true,
                                    :clean_working_copy => true,
                                    :message            => "I did it! I did it!! Hell yeah!!!")
    end

    describe "with empty committer name" do
      before(:each) do
        @operation.committer_name = ""
      end

      it "is NOT valid for committing" do
        # empty string is not considered present for
        # a String value
        @operation.should_not be_valid_for_committing

        # sanity check since this empty vs blank vs nil
        # thing is a shaky ground
        @operation.committer_name = "l33t k0dr"
        @operation.should be_valid_for_committing
      end

      it "IS valid for pushing" do
        @operation.should be_valid_for_pushing
      end

      it "IS valid for pulling" do
        @operation.should be_valid_for_pulling
      end

      it "is not valid in default context" do
        @operation.should_not be_valid
      end
    end # describe "with empty committer field"


    describe "with empty author name" do
      before(:each) do
        @operation.author_name = ""
      end

      it "is NOT valid for committing" do
        # empty string is not considered present for
        # a String value
        @operation.should_not be_valid_for_committing

        # sanity check since this empty vs blank vs nil
        # thing is a shaky ground
        @operation.author_name = "l33t k0dr"
        @operation.should be_valid_for_committing
      end

      it "IS valid for pushing" do
        @operation.should be_valid_for_pushing
      end

      it "IS valid for pulling" do
        @operation.should be_valid_for_pulling
      end

      it "is not valid in default context" do
        @operation.should_not be_valid
      end
    end # describe "with empty author field"
  end # describe GitOperation
end # if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
