class Viewable
  include DataMapper::CouchResource

  def self.default_repository_name
    :couch
  end

  property :name, String
  property :open, Boolean
end
