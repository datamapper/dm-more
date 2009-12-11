require 'spec_helper'
require 'integration/format_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::BillOfLading' do
  before :all do
    DataMapper::Validate::Fixtures::BillOfLading.auto_migrate!
  end

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
        @model.errors.on(:url).should == [ 'Url has an invalid format' ]
      end
    end
  end


  [ 'http://apple.com',
    'http://www.apple.com',
    "http://apple.com/",
    "http://apple.com/iphone",
    "http://www.google.com/search?client=safari&rls=en-us&q=LED&ie=UTF-8&oe=UTF-8",
    "http://books.google.com",
    "http://books.google.com/",
    "http://db2.clouds.megacorp.net:8080",
    "https://github.com",
    "https://github.com/",
    "http://www.example.com:8088/never/ending/path/segments/",
    "http://db2.clouds.megacorp.net:8080/resources/10",
    "http://www.example.com:8088/never/ending/path/segments",
    "http://books.google.com/books?id=uSUJ3VhH4BsC&printsec=frontcover&dq=subject:%22+Linguistics+%22&as_brr=3&ei=DAHPSbGQE5rEzATk1sShAQ&rview=1",
    "http://books.google.com:80/books?uid=14472359158468915761&rview=1",
    "http://books.google.com/books?id=Ar3-TXCYXUkC&printsec=frontcover&rview=1",
    "http://books.google.com/books/vp6ae081e454d30f89b6bca94e0f96fc14.js",
    "http://www.google.com/images/cleardot.gif",
    "http://books.google.com:80/books?id=Ar3-TXCYXUkC&printsec=frontcover&rview=1#PPA5,M1",
    "http://www.hulu.com/watch/64923/terminator-the-sarah-connor-chronicles-to-the-lighthouse",
    "http://hulu.com:80/browse/popular/tv",
    "http://www.hulu.com/watch/62475/the-simpsons-gone-maggie-gone#s-p1-so-i0"
  ].each do |uri|
   describe "with URL of #{uri}" do
     before :all do
       @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:url => uri))
     end

     it_should_behave_like "valid model"
   end
 end
end
