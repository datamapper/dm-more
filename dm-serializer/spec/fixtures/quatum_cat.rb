class QuantumCat
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :location, String

  repository(:alternate) do
    property :is_dead, Boolean
  end
end
