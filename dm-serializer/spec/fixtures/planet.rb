class Planet
  include DataMapper::Resource

  property :name,     String, :key => true
  property :aphelion, Float

  validates_length_of :name, :min => 2

  # Sorry these associations don't make any sense
  # I just needed a many-to-many association to test against
  has n, :friended_planets
  has n, :friend_planets, :through => :friended_planets, :model => 'Planet'

  belongs_to :solar_system

  def category
    case self.name.downcase
    when "mercury", "venus", "earth", "mars" then "terrestrial"
    when "jupiter", "saturn", "uranus", "neptune" then "gas giants"
    when "pluto" then "dwarf planets"
    end
  end

  def has_known_form_of_life?
    self.name.downcase == "earth"
  end
end

class FriendedPlanet
  include DataMapper::Resource

  property :planet_name,        String, :key => true
  property :friend_planet_name, String, :key => true

  belongs_to :planet, :child_key => [ :planet_name ]
  belongs_to :friend_planet, :model => 'Planet', :child_key => [ :friend_planet_name ]
end

class SolarSystem
  include DataMapper::Resource

  property :id, Serial

  property :name, String

end
