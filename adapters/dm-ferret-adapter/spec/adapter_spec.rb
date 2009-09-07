require 'spec_helper'

INDEX_PATH = Pathname(__FILE__).dirname.expand_path + 'index'

describe DataMapper::Adapters::FerretAdapter do
  before do
    @adapter = DataMapper.setup(:default, "ferret://#{INDEX_PATH}")

    Object.send(:remove_const, :User) if defined?(User)
    class ::User
      include DataMapper::Resource

      property :id, Serial
    end

    Object.send(:remove_const, :Photo) if defined?(Photo)
    class ::Photo
      include DataMapper::Resource

      property :uuid, String, :default => proc { UUIDTools::UUID.random_create }, :key => true
      property :happy, Boolean, :default => true
    end
  end

  after do
    FileUtils.rm_r(INDEX_PATH)
  end

  it 'should work with a model using id' do
    u = User.create(:id => 2)
    repository.search('*').should == { User => %w[ 2 ] }
  end

  it 'should work with a model using another key than id' do
    p = Photo.create
    repository.search('*').should == { Photo => [p.uuid] }
  end

  it 'should allow lookups using Model#get' do
    u = User.create(:id => 2)
    User.get(2).should == u
  end
end
