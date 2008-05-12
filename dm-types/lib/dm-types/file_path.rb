require 'pathname'

module DataMapper
  module Types
    class FilePath < DataMapper::Type
      primitive String

      def self.load(value, property)
        if value.nil?
          nil
        else
          Pathname.new(value)
        end
      end

      def self.dump(value, property)
        return nil if value.nil?
        value.to_s
      end
    end # class FilePath
  end # module Types
end # module DataMapper
