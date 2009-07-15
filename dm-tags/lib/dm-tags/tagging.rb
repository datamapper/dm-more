class Tagging
  include DataMapper::Resource

  property :id,            Serial
  property :taggable_id,   Integer, :nullable => false
  property :taggable_type, Class,   :nullable => false
  property :tag_context,   String,  :nullable => false

  belongs_to :tag

  if respond_to?(:validates_present)
    validates_present :taggable_type, :taggable_id
  end

  def taggable
    taggable_type.get!(taggable_id)
  end
end
