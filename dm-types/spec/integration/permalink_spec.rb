require 'pathname'
require 'iconv'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Permalink do
  
  before(:all) do
    class PermalinkTest
      include DataMapper::Resource

      property :id, Serial
      property :name, Permalink
      
    end
    PermalinkTest.auto_migrate!
  end
  
  it "should create the permalink" do
    repository(:default) do
      PermalinkTest.create(:name => 'New DataMapper Type')
    end

    PermalinkTest.first.name.should == create_permalink("New DataMapper Type")
  end

  
  def create_permalink(word)
    Iconv.new('UTF-8//TRANSLIT//IGNORE', 'UTF-8').iconv(word.gsub(/[^\w\s\-\—]/,'').gsub(/[^\w]|[\_]/,' ').split.join('-').downcase)
  end
  
end