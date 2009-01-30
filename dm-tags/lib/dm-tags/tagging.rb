class Tagging
  include DataMapper::Resource

  property :id,            Serial
  property :tag_id,        Integer, :nullable => false
  property :taggable_id,   Integer, :nullable => false
  property :taggable_type, String,  :nullable => false
  property :tag_context,   String,  :nullable => false

  belongs_to :tag

  if respond_to?(:validates_present)
    validates_present :taggable_type, :taggable_id
  end

  def taggable
    Object.const_get(taggable_type).send(:get!, taggable_id)
  end
end
