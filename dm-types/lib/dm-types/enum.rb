module DataMapper
  module Types
    class Enum < DataMapper::Type(Fixnum)

      def self.flag_map
        @flag_map
      end

      def self.flag_map=(value)
        @flag_map = value
      end

      def self.new(*flags)
        enum = Enum.dup
        enum.flag_map = {}

        flags.each_with_index do |flag, i|
          enum.flag_map[i + 1] = flag
        end

        enum
      end

      def self.[](*flags)
        new(*flags)
      end

      def self.load(value, property)
        self.flag_map[value]
      end

      def self.dump(value, property)
        self.flag_map.invert[value]
      end
    end # class Enum
  end # module Types
end # module DataMapper
