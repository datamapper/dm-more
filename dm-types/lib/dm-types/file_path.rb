require 'pathname'

module DataMapper
  module Types
    class FilePath < DataMapper::Type
      primitive String
      length    255

      def self.load(value, property)
        if value.blank?
          nil
        else
          Pathname.new(value)
        end
      end

      def self.dump(value, property)
        return nil if value.blank?
        value.to_s
      end

      def self.typecast(value, property)
        # Leave alone if a Pathname is given.
        value.kind_of?(Pathname) ? value : load(value, property)
      end
    end # class FilePath
  end # module Types
end # module DataMapper
