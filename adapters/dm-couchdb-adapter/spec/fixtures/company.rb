class Company
  include DataMapper::CouchResource

  def self.default_repository_name
    :couch
  end

  # This class happens to have similar properties
  property :name, String
  property :age,  Integer

  has n, :users
end
