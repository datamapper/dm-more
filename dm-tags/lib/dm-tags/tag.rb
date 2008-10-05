class Tag
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :name, String, :nullable => false, :unique => true

  has n, :taggings

  def taggables
    taggings.map{|tagging| tagging.taggable}
  end
end
