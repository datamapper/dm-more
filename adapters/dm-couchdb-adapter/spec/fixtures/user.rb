class User
  include DataMapper::CouchResource

  def self.default_repository_name
    :couch
  end

  # regular properties
  property :name,       String
  property :age,        Integer
  property :wealth,     Float
  property :created_at, DateTime
  property :created_on, Date
  property :location,   JsonObject

  # creates methods for accessing stored/indexed views in the CouchDB database
  view(:by_name) {{ "map" => "function(doc) { if (#{couchdb_types_condition}) { emit(doc.name, doc); } }" }}
  view(:by_age)  {{ "map" => "function(doc) { if (#{couchdb_types_condition}) { emit(doc.age, doc); } }" }}
  view(:count)   {{ "map" => "function(doc) { if (#{couchdb_types_condition}) { emit(null, 1); } }",
                    "reduce" => "function(keys, values) { return sum(values); }" }}

  belongs_to :company

  before :create do
    self.created_at = DateTime.now
    self.created_on = Date.today
  end
end
