require 'pathname'
require 'iconv'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Stub do

  before(:all) do
    class StubTest
      include DataMapper::Resource

      property :id, Serial
      property :name, Stub

    end
    StubTest.auto_migrate!
  end

  it "should create the permalink" do
    repository(:default) do
      StubTest.create(:name => 'New DataMapper Type')
    end

    StubTest.first.name.should == create_stub("New DataMapper Type")
  end
  
  it "should find by a stub" do
    repository(:default) do
      StubTest.create(:name => "This Should Be a Stub")
    end
    stub = create_stub( "This Should Be a Stub")
    
    stubbed = StubTest.first(:name => stub)
    stubbed.should_not be_nil
    stubbed.name.should == stub
  end


  def create_stub(word)
    Iconv.new('UTF-8//TRANSLIT//IGNORE', 'UTF-8').iconv(word.gsub(/[^\w\s\-\—]/,'').gsub(/[^\w]|[\_]/,' ').split.join('-').downcase)
  end

end
