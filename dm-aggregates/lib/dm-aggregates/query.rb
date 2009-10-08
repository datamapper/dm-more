module DataMapper
  module Aggregates
    module Query
      def self.included(base)
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # FIXME: figure out a cleaner approach than AMC
          alias assert_valid_fields_without_operator assert_valid_fields
          alias assert_valid_fields assert_valid_fields_with_operator
        RUBY
      end

      def assert_valid_fields_with_operator(fields, unique)
        operators, fields = fields.partition { |f| f.kind_of?(DataMapper::Query::Operator) }

        operators.each do |operator|
          target = operator.target

          unless target == :all || @properties.include?(target)
            raise ArgumentError, "+options[:fields]+ entry #{target.inspect} does not map to a property in #{model}"
          end
        end

        assert_valid_fields_without_operator(fields, unique)
      end
    end
  end
end
