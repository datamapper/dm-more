require 'pathname'
require Pathname(__FILE__).dirname + 'ferret_adapter/version'

require 'ferret'

module DataMapper
  module Adapters
    class FerretAdapter < AbstractAdapter
      def initialize(name, options)
        super
        @index = unless File.extname(@options[:path]) == '.sock'
          LocalIndex.new(@options)
        else
          RemoteIndex.new(@options)
        end
      end

      def create(resources)
        resources.each do |resource|
          attributes = resource.attributes(:field).to_mash

          # Since we don't inspect the models before generating the indices,
          # we'll map the resource's key to the :id column.
          attributes[:id]    ||= resource.key.first
          attributes[:_type]   = resource.model.name

          @index.add attributes
        end
      end

      # This returns an array of Ferret docs (glorified hashes) which can
      # be used to instantiate objects by doc[:_type] and doc[:_id]
      def read(query)
        fields = query.fields
        key    = query.model.key(name).first

        ferret_query = dm_query_to_ferret_query(query)

        @index.search(ferret_query, :limit => query.limit).map do |lazy_doc|
          fields.map { |p| [ p, p.typecast(lazy_doc[p.field]) ] }.to_hash.update(
            key.field => key.typecast(lazy_doc[:id])
          )
        end
      end

      def delete(collection)
        @index.delete dm_query_to_ferret_query(collection.query)
        1
      end

      # This returns a hash of the resource constant and the ids returned for it
      # from the search.
      #   { Story => ["1", "2"], Image => ["2"] }
      def search(ferret_query, limit = :all)
        results = {}
        @index.search(ferret_query, :limit => limit).each do |doc|
          resources = results[Object.const_get(doc[:_type])] ||= []
          resources << doc[:id]
        end
        results
      end

      private

      def dm_query_to_ferret_query(query)
        # We scope the query by the _type field to the query's model.
        statements = [ "+_type:#{quote_value(query.model.name)}" ]

        if query.conditions.operands.empty?
          statements << '*'
        else
          # TODO: make this work with the new Query conditions system
          statements << "#{conditions_statement(query.conditions)}"
        end

        statements.join(' ')
      end

      def conditions_statement(conditions)
        case conditions
          when Query::Conditions::NotOperation       then negate_operation(conditions)
          when Query::Conditions::AbstractOperation  then operation_statement(conditions)
          when Query::Conditions::AbstractComparison then comparison_statement(conditions)
        end
      end

      def negate_operation(operation)
        "NOT (#{conditions_statement(operation.operands.first)})"
      end

      def operation_statement(operation)
        statements  = []

        operation.each do |operand|
          statement = conditions_statement(operand)

          if operand.respond_to?(:operands) && operand.operands.size > 1
            statement = "(#{statement})"
          end

          statements << statement
        end

        join_with = operation.kind_of?(Query::Conditions::AndOperation) ? 'AND' : 'OR'
        statements.join(" #{join_with} ")
      end

      def comparison_statement(comparison)
        value = comparison.value

        # TODO: move exclusive Range handling into another method, and
        # update conditions_statement to use it

        # break exclusive Range queries up into two comparisons ANDed together
        if value.kind_of?(Range) && value.exclude_end?
          operation = Query::Conditions::BooleanOperation.new(:and,
            Query::Conditions::Comparison.new(:gte, comparison.subject, value.first),
            Query::Conditions::Comparison.new(:lt,  comparison.subject, value.last)
          )

          return "(#{operation_statement(operation)})"
        end

        operator = case comparison
          when Query::Conditions::EqualToComparison              then ''
          when Query::Conditions::InclusionComparison            then raise NotImplementedError, 'no support for inclusion match yet'
          when Query::Conditions::RegexpComparison               then raise NotImplementedError, 'no support for regexp match yet'
          when Query::Conditions::LikeComparison                 then raise NotImplementedError, 'no support for like match yet'
          when Query::Conditions::GreaterThanComparison          then '>'
          when Query::Conditions::LessThanComparison             then '<'
          when Query::Conditions::GreaterThanOrEqualToComparison then '>='
          when Query::Conditions::LessThanOrEqualToComparison    then '<='
        end

        # We use property.field here, so that you can declare composite
        # fields:
        #     property :content, String, :field => "title|description"
        [ "+#{comparison.subject.field}:", quote_value(value) ].join(operator)
      end

      def quote_value(value)
        value.kind_of?(Numeric) ? value : "\"#{value}\""
      end
    end
  end
end

require Pathname(__FILE__).dirname + "ferret_adapter/local_index"
require Pathname(__FILE__).dirname + "ferret_adapter/remote_index"
require Pathname(__FILE__).dirname + "ferret_adapter/repository_ext"
