class Tagging
  include DataMapper::Resource

  property :id,            Serial
  property :taggable_id,   Integer, :required => true, :min => 1
  property :taggable_type, Class,   :required => true
  property :tag_context,   String,  :required => true

  belongs_to :tag

  def taggable
    taggable_type.get!(taggable_id)
  end
end
