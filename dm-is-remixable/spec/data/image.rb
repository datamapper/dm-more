module Image
  include DataMapper::Resource

  is :remixable

  property :id,           Integer, :key => true, :serial => true
  property :description,  String
  property :path,         String
end
