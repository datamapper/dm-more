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
        elsif value.kind_of?(Array)
          super(value, property)
        elsif value.kind_of?(String)
          v = (value || "").split(",").
            compact.
            map { |i| i.downcase.strip }.
            reject { |i| i.blank? }.
            uniq
          super(v, property)
        else
          raise ArgumentError, "+value+ of CommaSeparatedList must be a string, an array or nil, but given #{value.inspect}"
        end
      end # self.dump
    end # CommaSeparatedList

  end # Types
end # DataMapper
