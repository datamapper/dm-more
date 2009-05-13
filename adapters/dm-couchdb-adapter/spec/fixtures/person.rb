class Person
  include DataMapper::CouchResource

  def self.default_repository_name
    :couch
  end

  property :type, Discriminator
  property :name, String

  view(:by_name) {{ "map" => "function(doc) { if (#{couchdb_types_condition}) { emit(doc.name, doc); } }" }}
end
