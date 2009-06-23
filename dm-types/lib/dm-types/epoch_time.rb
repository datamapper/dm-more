module DataMapper
  module Types
    class EpochTime < DataMapper::Type
      primitive Integer

      def self.load(value, property)
        if value.kind_of?(Integer)
          Time.at(value)
        else
          value
        end
      end

      def self.dump(value, property)
        case value
          when Integer, Time then value.to_i
          when DateTime      then value.to_time.to_i
        end
      end
    end # class EpochTime
  end # module Types
end # module DataMapper
