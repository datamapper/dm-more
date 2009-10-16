class DifficultBook
  include DataMapper::Resource

  storage_names[:default] = 'books'

  property :id,         Serial
  property :created_at, DateTime
  property :title,      String
  property :author,     String
end
