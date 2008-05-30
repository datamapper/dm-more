class Planet
  include DataMapper::Resource

  property :name, String, :key => true
  property :aphelion, Float

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
