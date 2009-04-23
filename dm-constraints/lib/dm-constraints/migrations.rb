module DataMapper
  module Constraints
    module Migrations
      module SingletonMethods
        def self.included(base)
          base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            alias_method :auto_migrate_down_without_constraints!, :auto_migrate_down!
            alias_method :auto_migrate_down!, :auto_migrate_down_with_constraints!

            alias_method :auto_migrate_up_without_constraints!, :auto_migrate_up!
            alias_method :auto_migrate_up!, :auto_migrate_up_with_constraints!
          RUBY
        end

        def auto_migrate_down_with_constraints!(repository_name = nil)
          original_repository_name = repository_name

          with_each_model_and_repository(repository_name) do |model, repository_name|
            next unless model.storage_exists?(repository_name)
            adapter = DataMapper.repository(repository_name).adapter
            next unless adapter.respond_to?(:destroy_constraints_statements)
            statements = adapter.destroy_constraints_statements(model)
            statements.each { |s| adapter.execute(s) }
          end

          auto_migrate_down_without_constraints!(original_repository_name)
        end

        def auto_migrate_up_with_constraints!(repository_name)
          auto_migrate_up_without_constraints!(repository_name)

          with_each_model_and_repository(repository_name) do |model, repository_name|
            adapter = DataMapper.repository(repository_name).adapter
            next unless adapter.respond_to?(:create_constraints_statements)
            statements = adapter.create_constraints_statements(model)
            statements.each { |s| adapter.execute(s) }
          end
        end
      end

      module DataObjectsAdapter
        ##
        # Determine if a constraint exists for a table
        #
        # @param storage_name [Symbol]
        #   name of table to check constraint on
        # @param constraint_name [~String]
        #   name of constraint to check for
        #
        # @return [Boolean]
        #
        # @api private
        def constraint_exists?(storage_name, constraint_name)
          statement = <<-SQL.compress_lines
            SELECT COUNT(*)
            FROM "information_schema"."table_constraints"
            WHERE "constraint_type" = 'FOREIGN KEY'
            AND "table_schema" = ?
            AND "table_name" = ?
            AND "constraint_name" = ?
          SQL

          query(statement, schema_name, storage_name, constraint_name).first > 0
        end

        # TODO: add create_model_constraint
        # TODO: add destroy_model_constraint

        module SQL

          ##
          # generates all foreign key create constraint statements for valid relationships
          #   given repository and a model
          #
          # This wraps calls to create_constraints_statement
          #
          # @see #create_constraints_statement
          #
          # @param model [DataMapper::Model]
          #   Model to constrain
          #
          # @return [Array[String]]
          #   List of statements to create constraints
          #
          # @api public
          def create_constraints_statements(model)
            model.relationships(name).map do |relationship_name, relationship|
              next unless relationship.kind_of?(DataMapper::Associations::ManyToOne::Relationship)
              next unless relationship.source_repository_name == relationship.target_repository_name

              source_model = relationship.source_model
              source_table = source_model.storage_name(name)
              source_key   = relationship.source_key

              constraint_name = constraint_name(source_table, relationship.name)
              next if constraint_exists?(source_table, constraint_name)

              # TODO: add a method to dm-core Reltionship to identify the back reference
              reverse_relationship = relationship.target_model.relationships(name).values.detect do |reverse|
                reverse.target_repository_name == name         &&
                reverse.target_model           == source_model &&
                reverse.target_key             == source_key   &&
                reverse.query.empty?

                # TODO: handle case where @query is not empty, but scoped the same as the target model.
                # that case should be treated the same as the Query being empty
              end

              constraint_type = case reverse_relationship && reverse_relationship.constraint || :protect
                when :protect            then 'NO ACTION'
                when :destroy, :destroy! then 'CASCADE'
                when :set_nil            then 'SET NULL'
                when :skip               then nil
              end

              next if constraint_type.nil?

              repository = DataMapper.repository(name)

              storage_name           = relationship.source_model.storage_name(name)
              reference_storage_name = relationship.target_model.storage_name(name)

              foreign_keys   = relationship.source_key.map { |p| property_to_column_name(p, false) }
              reference_keys = relationship.target_key.map { |p| property_to_column_name(p, false) }

              create_constraints_statement(constraint_name, constraint_type, storage_name, foreign_keys, reference_storage_name, reference_keys)
            end.compact
          end

          ##
          # generates all foreign key destroy constraint statements for valid relationships
          #   given repository and a model
          #
          # This wraps calls to destroy_constraints_statement
          #
          # @see #destroy_constraints_statement
          #
          # @param model [DataMapper::Model]
          #   Model to constrain
          #
          # @return [Array[String]]
          #   List of statements to destroy constraints
          #
          # @api public
          def destroy_constraints_statements(model)
            model.relationships(name).map do |relationship_name, relationship|
              next unless relationship.kind_of?(Associations::ManyToOne::Relationship)
              next unless relationship.source_repository_name == relationship.target_repository_name

              source_model = relationship.source_model
              source_table = source_model.storage_name(name)

              constraint_name = constraint_name(source_table, relationship.name)
              next unless constraint_exists?(source_table, constraint_name)

              destroy_constraints_statement(source_table, constraint_name)
            end.compact
          end

          private

          ##
          # Generates the SQL statement to create a constraint
          #
          # @param constraint_name [String]
          #   name of the foreign key constraint
          # @param constraint_type [String]
          #   type of foreign key constraint to add to the table
          # @param storage_name [String]
          #   name of table to constrain
          # @param foreign_keys [Array[String]]
          #   columns in the table that refer to foreign table
          # @param reference_storage_name [String]
          #   table the foreign key refers to
          # @param reference_storage_name [Array[String]]
          #   columns the foreign table that are referred to
          #
          # @return [String]
          #   SQL DDL Statement to create a constraint
          #
          # @api private
          def create_constraints_statement(constraint_name, constraint_type, storage_name, foreign_keys, reference_storage_name, reference_keys)
            <<-SQL.compress_lines
              ALTER TABLE #{quote_name(storage_name)}
              ADD CONSTRAINT #{quote_name(constraint_name)}
              FOREIGN KEY (#{foreign_keys.join(', ')})
              REFERENCES #{quote_name(reference_storage_name)} (#{reference_keys.join(', ')})
              ON DELETE #{constraint_type}
              ON UPDATE #{constraint_type}
            SQL
          end

          ##
          # Generates the SQL statement to destroy a constraint
          #
          # @param storage_name [String]
          #   name of table to constrain
          # @param constraint_name [String]
          #   name of foreign key constraint
          #
          # @return [String]
          #   SQL DDL Statement to destroy a constraint
          #
          # @api private
          def destroy_constraints_statement(storage_name, constraint_name)
            <<-SQL.compress_lines
              ALTER TABLE #{quote_name(storage_name)}
              DROP CONSTRAINT #{quote_name(constraint_name)}
            SQL
          end

          ##
          # generates a unique constraint name given a table and a relationships
          #
          # @param storage_name [String]
          #   name of table to constrain
          # @param relationships_name [String]
          #   name of the relationship to constrain
          #
          # @return [String]
          #   name of the constraint
          #
          # @api private
          def constraint_name(storage_name, relationship_name)
            "#{storage_name}_#{relationship_name}_fk"
          end
        end

        include SQL
      end

      module MysqlAdapter
        module SQL
          private

          ##
          # MySQL specific query to drop a foreign key
          #
          # @param storage_name [String]
          #   name of table to constrain
          # @param constraint_name [String]
          #   name of foreign key constraint
          #
          # @return [String]
          #   SQL DDL Statement to destroy a constraint
          #
          # @api private
          def destroy_constraints_statement(storage_name, constraint_name)
            <<-SQL.compress_lines
              ALTER TABLE #{quote_name(storage_name)}
              DROP FOREIGN KEY #{quote_name(constraint_name)}
            SQL
          end
        end

        include SQL
      end
    end
  end
end
