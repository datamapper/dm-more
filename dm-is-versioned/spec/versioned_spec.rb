require File.dirname(__FILE__) + "/spec_helper"

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::Versioned' do
    before :all do
      class Form
        include DataMapper::Resource
        include DataMapper::Is::Versioned

        property :id, Integer, :serial => true
        property :name, String

        is_versioned

        auto_migrate!(:default)
      end

      Form.create!(:id => 1, :name => "Important form")
    end

    describe "Class#is_versioned" do\

      it "adds a version property with a default value of 0" do
        Form.first.version.should == 0
      end

      it "creates a model for storing older versions" do
        lambda { FormVersion}.should_not raise_error(NameError)
      end

    end
  end
end
