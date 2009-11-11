class Cow
  include DataMapper::Resource

  property :id,        Integer, :key => true
  property :composite, Integer, :key => true
  property :name,      String
  property :breed,     String

  belongs_to :mother_cow, :model => self, :required => false
  has n, :baby_cows, :model => self, :child_key => [ :mother_cow_id, :mother_cow_composite ]
end
