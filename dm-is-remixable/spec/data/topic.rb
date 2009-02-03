require Pathname(__FILE__).dirname / "rating"

class Topic
  include DataMapper::Resource

  property :id, Serial

  property :name, String
  property :description, String

  remix n, My::Nested::Remixable::Rating,
    :as => :ratings_for_topic,
    :model => "Rating"

end
