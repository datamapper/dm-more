module Commentable
  include DataMapper::Resource

  is :remixable,
    :suffix => "comment"

  property :id,         Serial
  property :comment,    String
  property :created_at, DateTime

  validates_presence_of :comment, :context => [ :publish ]

end
