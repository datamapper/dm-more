require "pathname"
require Pathname(__FILE__).dirname + "helper"

class User
  include DataMapper::Resource
  property :id, Serial
end

class Photo
  include DataMapper::Resource
  property :uuid, String, :default => lambda { `uuidgen`.chomp }, :key => true
end

describe "FerretAdapter" do
  before :each do
    @index = Pathname(__FILE__).dirname.expand_path + "index"
    DataMapper.setup :search, "ferret://#{@index}"
  end

  after :each do
    FileUtils.rm_r(@index)
  end

  it "should work with a model using id" do
    u = User.new(:id => 2)
    repository(:search).create([u])
    repository(:search).search("*").should == { User => ["2"] }
  end

  it "should work with a model using another key than id" do
    p = Photo.new
    repository(:search).create([p])
    repository(:search).search("*").should == { Photo => [p.uuid] }
  end
end
