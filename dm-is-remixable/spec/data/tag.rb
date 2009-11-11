class Tag
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :unique => true, :required => true
end
