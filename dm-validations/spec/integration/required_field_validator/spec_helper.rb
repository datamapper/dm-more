if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  class Landscaper
    include DataMapper::Resource

    #
    # Properties
    #

    property :id, Integer, :key => true
    property :name, String
  end

  class Garden
    include DataMapper::Resource

    #
    # Properties
    #

    property :id,            Integer, :key => true
    property :landscaper_id, Integer
    property :name,          String, :auto_validation => false

    #
    # Associations
    #

    belongs_to :landscaper

    #
    # Validations
    #

    validates_present :name, :when => :property_test
    validates_present :landscaper, :when => :association_test
  end
  
  class Fertilizer
    include DataMapper::Resource

    #
    # Properties
    #

    property :id,    Integer, :serial => true
    property :brand, String, :auto_validation => false, :default => 'Scotts'

    #
    # Validations
    #

    validates_present :brand, :when => :property_test
  end
  
  Landscaper.auto_migrate!
  Garden.auto_migrate!
  Fertilizer.auto_migrate!
end