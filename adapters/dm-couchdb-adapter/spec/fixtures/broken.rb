class Broken
  include DataMapper::CouchResource

  def self.default_repository_name
    :couch
  end

  property :couchdb_type, Discriminator
  property :name,         String
end
