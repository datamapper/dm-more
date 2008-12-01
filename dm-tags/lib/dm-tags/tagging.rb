class Tagging
  include DataMapper::Resource

  property :id,            Serial
  property :tag_id,        Integer, :nullable => false
  property :taggable_id,   Integer, :nullable => false
  property :taggable_type, String,  :nullable => false
  property :tag_context,   String,  :nullable => false

  belongs_to :tag

  def taggable
    eval("#{taggable_type}.get!(#{taggable_id})") if taggable_type and taggable_id
  end
end
