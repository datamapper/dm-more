module DataMapper
  module Types
    class Flag < Type
      primitive Integer

      def self.inherited(target)
        target.instance_variable_set('@primitive', self.primitive)
      end

      def self.flag_map
        @flag_map
      end

      def self.flag_map=(value)
        @flag_map = value
      end

      def self.new(*flags)
        type = Class.new(Flag)
        type.flag_map = {}

        flags.each_with_index do |flag, i|
          type.flag_map[i] = flag
        end

        type
      end

      def self.[](*flags)
        new(*flags)
      end

      def self.load(value, property)
        return [] if value.nil? || value <= 0

        begin
          matches = []

          0.upto(flag_map.size - 1) do |i|
            matches << flag_map[i] if value[i] == 1
          end

          matches.compact
        rescue TypeError, Errno::EDOM
          []
        end
      end

      def self.dump(value, property)
        return if value.nil?
        flags = Array(value).map { |flag| flag.to_sym }.flatten
        flag_map.invert.values_at(*flags).compact.inject(0) { |sum, i| sum += 1 << i }
      end

      def self.typecast(value, property)
        case value
          when nil   then nil
          when Array then value.map {|v| v.to_sym}
          else value.to_sym
        end
      end
    end # class Flag
  end # module Types
end # module DataMapper
