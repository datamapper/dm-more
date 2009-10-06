if RUBY_VERSION >= '1.9.0'
  require 'csv'
else
  require 'fastercsv'  # must be ~>1.5
  CSV = FasterCSV unless defined?(CSV)
end

module DataMapper
  module Types
    class Csv < DataMapper::Type
      primitive Text

      def self.load(value, property)
        case value
          when String then CSV.parse(value)
          when Array  then value
          else
            nil
        end
      end

      def self.dump(value, property)
        case value
          when Array  then CSV.generate { |csv| value.each { |row| csv << row } }
          when String then value
          else
            nil
        end
      end
    end # class Csv
  end # module Types
end # module DataMapper
