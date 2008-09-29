require 'uuidtools'

module DataMapper
  module Types
    # UUID Type
    # First run at this, because I need it. A few caveats:
    #  * Only works on postgres, using the built-in native uuid type. 
    #    To make it work in mysql, you'll have to add a typemap entry to
    #    the mysql_adapter. I think. I don't have mysql handy, so I'm
    #    not going to try. For SQLite, this will have to inherit from the 
    #    String primitive
    #  * Won't accept a random default, because of the namespace clash
    #    between this and the UUIDtools gem. Also can't set the default
    #    type to UUID() (postgres-contrib's native generator) and 
    #    automigrate, because auto_migrate! tries to make it a string "UUID()"
    # Feel free to enchance this, and delete these caveats when they're fixed.
    #
    #  -- Rando Sept 25, 08
    #  
    class UUID < DataMapper::Type
      primitive 'UUID'

      def self.load(value, property)
        return nil if value.nil?
        ::UUID.parse(value) 
      end

      def self.dump(value, property)
        return nil if value.nil?
        value.to_s
      end

      def self.typecast(value, property)
        value.kind_of?(::UUID) ? value : load(value, property)
      end

      ::DataMapper::Property::TYPES << self
      if defined? DataMapper::Adapters::PostgresAdapter
        DataMapper::Adapters::PostgresAdapter.type_map.map(self).to('UUID')
      end
    end
  end
end