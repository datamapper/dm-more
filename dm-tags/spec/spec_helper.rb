require 'pathname'
require 'rubygems'

gem 'dm-core', '~>0.9.7'
require 'dm-core'

gem 'dm-validations', '~>0.9.7'
require 'dm-validations'

spec_dir_path = Pathname(__FILE__).dirname.expand_path
require spec_dir_path.parent + 'lib/dm-tags'

DataMapper.setup(:default, 'sqlite3::memory:')

Spec::Runner.configure do |config|
  config.before(:each) do
    Object.send(:remove_const, :TaggedModel) if defined?(TaggedModel)
    class TaggedModel
      include DataMapper::Resource
      property :id, Serial

      has_tags_on :skills, :interests, :tags
    end

    Object.send(:remove_const, :AnotherTaggedModel) if defined?(AnotherTaggedModel)
    class AnotherTaggedModel
      include DataMapper::Resource
      property :id, Serial

      has_tags_on :skills, :pets
    end

    Object.send(:remove_const, :DefaultTaggedModel) if defined?(DefaultTaggedModel)
    class DefaultTaggedModel
      include DataMapper::Resource
      property :id, Serial

      has_tags
    end

    Object.send(:remove_const, :UntaggedModel) if defined?(UntaggedModel)
    class UntaggedModel
      include DataMapper::Resource
      property :id, Serial
    end

    DataMapper.auto_migrate!
  end
end
