module Viewable
  include DataMapper::Resource

  is :remixable,
    :suffix => "view"

  property :id, Serial

  property :created_at, DateTime
  property :ip, String
end
