require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe DataMapper::Validate::Fixtures::BillOfLading do
  def valid_attributes
    { :id => 1, :doc_no => 'A1234', :email => 'user@example.com', :url => 'http://example.com' }
  end

  [ 'http:// example.com', 'ftp://example.com', 'http://.com', 'http://', 'test', '...',
    # these are valid URIs from RFC perspective,
    # but too often not the case for web apps
    #
    # TODO: add another format that is strictly
    # RFC compliant so it can be used, for instance,
    # for internal apps that may refer to local domains
    # like http://backend:8080
    "http://localhost:4000", "http://localhost" ].each do |uri|
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


  [ 'http://apple.com', 'http://www.apple.com', "http://apple.com/", "http://apple.com/iphone",
    "http://www.google.com/search?client=safari&rls=en-us&q=LED&ie=UTF-8&oe=UTF-8",
    "http://books.google.com", "http://books.google.com/", "http://db2.clouds.megacorp.net:8080",
  "http://db2.clouds.megacorp.net:8080/resources/10"].each do |uri|
   describe "with URL of #{uri}" do
     before :all do
       @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:url => uri))
     end

     it_should_behave_like "valid model"
   end
 end # each
end # describe DataMapper::Validate::Fixtures::BillOfLading
