module DataMapper
  module Types

    class CommaSeparatedList < Yaml
      # this must be set even though Yaml already
      # uses String primitive
      #
      # current DM::Type behavior probably needs to
      # be improved for cases like this
      primitive String

      def self.dump(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          v = value.split(",").
            compact.
            map { |i| i.downcase.strip }.
            reject { |i| i.blank? }.
            uniq
          super(v, property)
        else
          raise ArgumentError.new("+value+ of a property of CommaSeparatedList type must be nil or a String")
        end
      end
    end
  end
end
