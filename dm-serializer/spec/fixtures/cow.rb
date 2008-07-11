class Cow
  include DataMapper::Resource

  property :id,        Integer, :key => true
  property :composite, Integer, :key => true
  property :name,      String
  property :breed,     String
  
  def self.serialize_properties(*args)
    [:extra, :another]
  end
  
  def extra
    "Extra"
  end
  
  def another
    42
  end
end
