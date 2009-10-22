module DataMapper
  module Aggregates
    module DataObjectsAdapter
      def self.included(base)
        base.send(:include, SQL)
      end

      def aggregate(query)
        fields = query.fields
        types  = fields.map { |p| p.respond_to?(:operator) ? String : p.primitive }

        field_size = fields.size

        records = []

        with_connection do |connection|
          statement, bind_values = select_statement(query)

          command = connection.create_command(statement)
          command.set_types(types)

          reader = command.execute_reader(*bind_values)

          begin
            while(reader.next!)
              row = fields.zip(reader.values).map do |field, value|
                if field.respond_to?(:operator)
                  send(field.operator, field.target, value)
                else
                  field.typecast(value)
                end
              end

              records << (field_size > 1 ? row : row[0])
            end
          ensure
            reader.close
          end
        end

        records
      end

      private

      def count(property, value)
        value.to_i
      end

      def min(property, value)
        property.typecast(value)
      end

      def max(property, value)
        property.typecast(value)
      end

      def avg(property, value)
        property.type == Integer ? value.to_f : property.typecast(value)
      end

      def sum(property, value)
        property.typecast(value)
      end

      module SQL
        def self.included(base)
          base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # FIXME: figure out a cleaner approach than AMC
            alias property_to_column_name_without_operator property_to_column_name
            alias property_to_column_name property_to_column_name_with_operator
          RUBY
        end

        def property_to_column_name_with_operator(property, qualify, qualifier = nil)
          case property
            when DataMapper::Query::Operator
              aggregate_field_statement(property.operator, property.target, qualify, qualifier)

            when Property, DataMapper::Query::Path
              property_to_column_name_without_operator(property, qualify, qualifier)

            else
              raise ArgumentError, "+property+ must be a DataMapper::Query::Operator, a DataMapper::Property or a Query::Path, but was a #{property.class} (#{property.inspect})"
          end
        end

        def aggregate_field_statement(aggregate_function, property, qualify, qualifier)
          column_name = if aggregate_function == :count && property == :all
            '*'
          else
            property_to_column_name(property, qualify, qualifier)
          end

          function_name = case aggregate_function
            when :count then 'COUNT'
            when :min   then 'MIN'
            when :max   then 'MAX'
            when :avg   then 'AVG'
            when :sum   then 'SUM'
            else raise "Invalid aggregate function: #{aggregate_function.inspect}"
          end

          "#{function_name}(#{column_name})"
        end
      end # module SQL
    end # class DataObjectsAdapter
  end # module Aggregates

  module Adapters
    extendable do

      # TODO: document
      # @api private
      def const_added(const_name)
        if DataMapper::Aggregates.const_defined?(const_name)
          adapter = const_get(const_name)
          adapter.send(:include, DataMapper::Aggregates.const_get(const_name))
        end

        super
      end
    end
  end # module Adapters
end # module DataMapper
