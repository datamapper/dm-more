class TaggedModel
  include DataMapper::Resource
  property :id, Integer, :serial => true

  has_tags_on :skills, :interests, :tags
end

class AnotherTaggedModel
  include DataMapper::Resource
  property :id, Integer, :serial => true

  has_tags_on :skills, :pets
end

class DefaultTaggedModel
  include DataMapper::Resource
  property :id, Integer, :serial => true

  has_tags
end

class UntaggedModel
  include DataMapper::Resource
  property :id, Integer, :serial => true
end
