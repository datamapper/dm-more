module DataMapper
  module Types
    class EpochTime < DataMapper::Type
      primitive Fixnum

      def self.load(value, property)
        case value
        when Integer
          Time.at(value)
        else
          value
        end
      end

      def self.dump(value, property)
        case value
        when Integer
          value
        when Time
          value.to_i
        when DateTime
          Time.parse(value.to_s).to_i
        end
      end
    end
  end
end