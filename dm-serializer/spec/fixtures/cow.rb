class Cow
  include DataMapper::Resource

  property :id,        Integer, :key => true
  property :composite, Integer, :key => true
  property :name,      String
  property :breed,     String

  has n, :baby_cows, :model => 'Cow'
  belongs_to :mother_cow, :model => 'Cow'
end
