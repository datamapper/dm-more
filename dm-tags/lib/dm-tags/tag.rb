class Tag
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :required => true, :unique => true, :unique_index => true

  has n, :taggings

  def taggables
    taggings.map { |tagging| tagging.taggable }
  end
end
