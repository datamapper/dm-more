require 'rubygems'
require 'pathname'

gem 'dm-core', '~>0.9.7'
require 'dm-core'

gem 'dm-validations', '~>0.9.7'
require 'dm-validations'

spec_dir_path = Pathname(__FILE__).dirname.expand_path
require spec_dir_path.parent + 'lib/dm-tags'

class TaggedModel
  include DataMapper::Resource
  property :id, Serial

  has_tags_on :skills, :interests, :tags
end

class AnotherTaggedModel
  include DataMapper::Resource
  property :id, Serial

  has_tags_on :skills, :pets
end

class DefaultTaggedModel
  include DataMapper::Resource
  property :id, Serial

  has_tags
end

class UntaggedModel
  include DataMapper::Resource
  property :id, Serial
end

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!
