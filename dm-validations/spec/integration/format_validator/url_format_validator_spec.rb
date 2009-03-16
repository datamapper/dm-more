require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe DataMapper::Validate::Fixtures::BillOfLading do
  def valid_attributes
    { :id => 1, :doc_no => 'A1234', :email => 'user@example.com', :url => 'http://example.com' }
  end

  [ 'http:// example.com', 'ftp://example.com', 'http://.com', 'http://', 'test', '...' ].each do |uri|
    describe "with URL of #{uri}" do
      before :all do
        @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:url => uri))
      end

      it_should_behave_like "invalid model"

      it "has a meaningful error message" do
        @model.errors.on(:url).should include('Url has an invalid format')
      end
    end
  end # each


 [ 'http://example.com', 'http://www.example.com', "http://apple.com", "http://books.google.com"].each do |uri|
   describe "with URL of #{uri}" do
     before :all do
       @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:url => uri))
     end

     it_should_behave_like "valid model"
   end
 end # each
end # describe DataMapper::Validate::Fixtures::BillOfLading