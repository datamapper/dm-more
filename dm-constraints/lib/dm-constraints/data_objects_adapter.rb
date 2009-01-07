module DataMapper
  module Constraints
    module DataObjectsAdapter
      module SQL
        def create_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            table_name      = model.storage_name(repository_name)
            constraint_name = constraint_name(table_name, relationship.name)
            next if constraint_exists?(table_name, constraint_name)

            keys          = relationship.child_key.map { |key| property_to_column_name(model.repository(repository_name), key, false) }
            parent        = relationship.parent_model
            foreign_table = parent.storage_name(repository_name)
            foreign_keys  = parent.key.map { |key| property_to_column_name(parent.repository(repository_name), key, false) }

            one_to_many_relationship = parent.relationships.values.select { |rel| rel.child_model == model }.first
            delete_constraint_type = case one_to_many_relationship.delete_constraint
            when :protect, nil
              "NO ACTION"
            when :destroy, :destroy!
              "CASCADE"
            when :nullify
              "SET NULL"
            when :skip
              nil
            end
            create_constraints_statement(table_name, constraint_name, keys, foreign_table, foreign_keys, delete_constraint_type) if delete_constraint_type
          end.compact
        end

        def destroy_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            table_name      = model.storage_name(repository_name)
            constraint_name = constraint_name(table_name, relationship.name)
            next unless constraint_exists?(table_name, constraint_name)

            destroy_constraints_statement(table_name, constraint_name)
          end.compact
        end

        private

        #TODO: ON (DELETE|UPDATE) CASCADE must be given for the 'destroy' case
        # ON (DELETE|UPDATE) SET NULL must be given for the 'nullify' case
        def create_constraints_statement(table_name, constraint_name, keys, foreign_table, foreign_keys, delete_constraint_type)
          <<-EOS.compress_lines
            ALTER TABLE #{quote_table_name(table_name)}
            ADD CONSTRAINT #{quote_constraint_name(constraint_name)}
            FOREIGN KEY (#{keys * ', '})
            REFERENCES #{quote_table_name(foreign_table)} (#{foreign_keys * ', '})
            ON DELETE #{delete_constraint_type}
            ON UPDATE #{delete_constraint_type}
          EOS
        end

        def destroy_constraints_statement(table_name, constraint_name)
          <<-EOS.compress_lines
            ALTER TABLE #{quote_table_name(table_name)}
            DROP CONSTRAINT #{quote_constraint_name(constraint_name)}
          EOS
        end

        def constraint_name(table_name, relationship_name)
          "#{table_name}_#{relationship_name}_fk"
        end

        def quote_constraint_name(foreign_key)
          quote_table_name(foreign_key)
        end
      end

      module Migration
        def self.included(migrator)
          migrator.extend(ClassMethods)
          migrator.before_class_method :auto_migrate_down, :auto_migrate_constraints_down
          migrator.after_class_method :auto_migrate_up, :auto_migrate_constraints_up
        end

        module ClassMethods
          def auto_migrate_constraints_down(repository_name, *descendants)
            descendants = DataMapper::Resource.descendants.to_a if descendants.empty?
            descendants.each do |model|
              if model.storage_exists?(repository_name)
                adapter = model.repository(repository_name).adapter
                next unless adapter.respond_to?(:destroy_constraints_statements)
                statements = adapter.destroy_constraints_statements(repository_name, model)
                statements.each {|stmt| adapter.execute(stmt) }
              end
            end
          end

          def auto_migrate_constraints_up(retval, repository_name, *descendants)
            descendants = DataMapper::Resource.descendants.to_a if descendants.empty?
            descendants.each do |model|
              adapter = model.repository(repository_name).adapter
              next unless adapter.respond_to?(:create_constraints_statements)
              statements = adapter.create_constraints_statements(repository_name, model)
              statements.each {|stmt| adapter.execute(stmt) }
            end
          end
        end
      end
    end
  end
end
