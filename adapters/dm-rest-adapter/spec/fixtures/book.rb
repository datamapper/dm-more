class Book
  include DataMapper::Resource

  property :author,     String
  property :created_at, DateTime
  property :id,         Serial
  property :title,      String
end
