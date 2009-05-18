class Book
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :title,      String
  property :author,     String
end
