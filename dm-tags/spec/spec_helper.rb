require 'pathname'
require 'rubygems'

gem 'dm-core', '0.9.12'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent.expand_path

# use local dm-validations if running from dm-more directly
lib = ROOT.parent.join('dm-validations', 'lib').expand_path
$LOAD_PATH.unshift(lib) if lib.directory?
require 'dm-validations'

require ROOT + 'lib/dm-tags'

DataMapper.setup(:default, 'sqlite3::memory:')

Spec::Runner.configure do |config|
  config.before(:each) do
    Object.send(:remove_const, :TaggedModel) if defined?(TaggedModel)
    class ::TaggedModel
      include DataMapper::Resource
      property :id, Serial

      has_tags_on :skills, :interests, :tags
    end

    Object.send(:remove_const, :AnotherTaggedModel) if defined?(AnotherTaggedModel)
    class ::AnotherTaggedModel
      include DataMapper::Resource
      property :id, Serial

      has_tags_on :skills, :pets
    end

    Object.send(:remove_const, :DefaultTaggedModel) if defined?(DefaultTaggedModel)
    class ::DefaultTaggedModel
      include DataMapper::Resource
      property :id, Serial

      has_tags
    end

    Object.send(:remove_const, :UntaggedModel) if defined?(UntaggedModel)
    class ::UntaggedModel
      include DataMapper::Resource
      property :id, Serial
    end

    DataMapper.auto_migrate!
  end
end
