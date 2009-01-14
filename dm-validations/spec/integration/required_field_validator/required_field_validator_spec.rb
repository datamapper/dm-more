require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe GitOperation do
    before :each do
      @operation = GitOperation.new
    end

    describe "unnamed SCM operation", :shared => true do
      before :each do
        @operation.name = nil
        @operation.valid?
      end

      it "is not valid" do
        @operation.should_not be_valid
      end

      it "is not valid in default validation context" do
        @operation.should_not be_valid(:default)
      end

      it "points to blank name in the error message" do
        @operation.errors.on(:name).should include('Name must not be blank')
      end
    end
  end



  # keep in mind any ScmOperation has a default value for brand property
  # so it is used
  describe GitOperation do
    before :each do
      @operation = GitOperation.new(:network_connection => true,
                                    :clean_working_copy => true,
                                    :message            => "I did it! I did it!! Hell yeah!!!")
    end

    describe "without operation name" do
      before(:each) do
        @operation.name = nil
      end
      it_should_behave_like "unnamed SCM operation"
    end

    describe "without explicitly specified committer name" do
      before :each do
        # no specific actions for this case! yay!
      end

      it "is valid for committing (because default value jumps in)" do
        @operation.should be_valid_for_committing
        @operation.should be_valid(:committing)
      end

      it "is not valid in default context" do
        # context here is :default
        @operation.should_not be_valid
      end

      it "has default value set" do
        # this is more of a sanity check since
        # this sort of functionality clearly needs to be
        # tested in
        @operation.committer_name.should == "Just another Ruby hacker"
      end
    end # describe "without explicitly specified committer name"

    describe "WITH explicitly specified committer name" do
      before :each do
        @operation.committer_name = "Core Team Guy"
      end

      it "is valid for committing" do
        @operation.should be_valid_for_committing
        @operation.should be_valid(:committing)
      end

      it "is not valid in default context" do
        @operation.should_not be_valid
        @operation.should_not be_valid(:default)
      end

      it "has value set" do
        # this is more of a sanity check since
        # this sort of functionality clearly needs to be
        # tested in
        @operation.committer_name.should == "Core Team Guy"
      end
    end # describe "with explicitly specified committer name"



    describe "without explicitly specified author name" do
      before :each do
        # no specific actions for this case! yay!
      end

      it "is valid for committing (because default value jumps in)" do
        @operation.should be_valid_for_committing
        @operation.should be_valid(:committing)
      end

      it "is not valid in default context" do
        # context here is :default
        @operation.should_not be_valid
        @operation.should_not be_valid(:default)
      end

      it "has default value set" do
        @operation.author_name.should == "Just another Ruby hacker"
      end
    end # describe "without explicitly specified author name"

    describe "WITH explicitly specified author name" do
      before :each do
        @operation.author_name = "Random contributor"
      end

      it "is valid for committing" do
        @operation.should be_valid_for_committing
      end

      it "is not valid in default context" do
        # context here is :default
        @operation.should_not be_valid
      end

      it "has value set" do
        @operation.author_name.should == "Random contributor"
      end
    end # describe "with explicitly specified author name"



    describe "without network connection" do
      before(:each) do
        # now note that false make sense from readability
        # point of view but is incorrect from validator
        # point of view ;)
        @operation.network_connection = nil
      end

      it "is valid for committing" do
        @operation.should be_valid_for_committing
        @operation.errors.on(:network_connection).should be_blank
      end

      it "is not valid for pushing" do
        @operation.should_not be_valid_for_pushing
        @operation.errors.on(:network_connection).
          first[:pushing].should include("cannot push without network connectivity")
      end

      it "is not valid for pulling" do
        @operation.should_not be_valid_for_pulling
        @operation.errors.on(:network_connection).
          first[:pulling].should include("you must have network connectivity to pull from others")
      end

      it "is not valid in default context" do
        @operation.should_not be_valid
      end
    end # describe "without network connection"

    describe "with a network connection" do
      before(:each) do
        @operation.network_connection = false
      end

      it "is valid for committing" do
        @operation.should be_valid_for_committing
      end

      it "is valid for pushing" do
        @operation.should be_valid_for_pushing
      end

      it "is valid for pulling" do
        @operation.should be_valid_for_pulling
      end

      it "is not valid in default context" do
        @operation.should_not be_valid
      end
    end # describe "with a network connection"


    describe "WITHOUT a clean working copy" do
      before(:each) do
        @operation.clean_working_copy = nil
      end

      it "is valid for committing" do
        @operation.should be_valid_for_committing
      end

      it "is valid for pushing" do
        @operation.should be_valid_for_pushing
      end

      it "is not valid for pulling" do
        @operation.should_not be_valid_for_pulling
      end

      it "is not valid in default context" do
        @operation.should_not be_valid
      end
    end # describe "without network connection"

    describe "with a clean working copy" do
      before(:each) do
        @operation.clean_working_copy = true
      end

      it "is valid for committing" do
        @operation.should be_valid_for_committing
      end

      it "is valid for pushing" do
        @operation.should be_valid_for_pushing
      end

      it "is valid for pulling" do
        @operation.should be_valid_for_pulling
      end

      it "is not valid in default context" do
        @operation.should_not be_valid
      end
    end # describe "with a network connection"
  end # describe GitOperation


  describe SubversionOperation do
    before(:each) do
      @operation = SubversionOperation.new :name    => "ci", :network_connection => true,
                                           :message => "v1.5.8", :clean_working_copy => true
    end

    describe "without operation name" do
      before(:each) do
        @operation.name = nil
      end
      it_should_behave_like "unnamed SCM operation"
    end

    describe "without network connection" do
      before(:each) do
        @operation.network_connection = nil
      end

      it "virtually useless" do
        @operation.should_not be_valid_for_committing
        @operation.should_not be_valid_for_log_viewing
      end
    end # describe "without network connection"
  end
end # if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
