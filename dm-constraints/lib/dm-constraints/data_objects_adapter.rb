module DataMapper
  module Constraints
    module DataObjectsAdapter
      module SQL
        def create_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            table_name      = model.storage_name(repository_name)
            keys            = relationship.child_key.map { |key| property_to_column_name(model.repository(repository_name), key, false) }
            parent          = relationship.parent_model
            foreign_table   = parent.storage_name(repository_name)
            foreign_keys    = parent.key.map { |key| property_to_column_name(parent.repository(repository_name), key, false) }
            <<-EOS.compress_lines
              ALTER TABLE #{quote_table_name(table_name)}
              ADD CONSTRAINT #{quote_constraint_name(constraint_name(table_name, relationship.name))}
              FOREIGN KEY (#{keys * ', '})
              REFERENCES #{quote_table_name(foreign_table)} (#{foreign_keys * ', '})
              ON DELETE NO ACTION
              ON UPDATE NO ACTION
            EOS
          end
        end

        def destroy_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            table_name      = model.storage_name(repository_name)
            constraint_name = constraint_name(table_name, relationship.name)
            next unless constraint_exists?(model.storage_name, constraint_name)
            <<-EOS.compress_lines
              ALTER TABLE #{quote_table_name(model.storage_name(repository_name))}
              DROP CONSTRAINT #{quote_constraint_name(constraint_name)}
            EOS
          end.compact
        end

        private

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
                statements = adapter.destroy_constraints_statements(repository_name, model)
                statements.each {|stmt| adapter.execute(stmt) }
              end
            end
          end

          def auto_migrate_constraints_up(retval, repository_name, *descendants)
            descendants = DataMapper::Resource.descendants.to_a if descendants.empty?
            descendants.each do |model|
              adapter = model.repository(repository_name).adapter
              statements = adapter.create_constraints_statements(repository_name, model)
              statements.each {|stmt| adapter.execute(stmt) }
            end
          end
        end
      end
    end
  end
end
