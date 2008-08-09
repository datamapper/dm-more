module DataMapper
  module Constraints
    module DataObjectsAdapter
      module SQL
        def create_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            parent        = relationship.parent_model
            foreign_table = parent.storage_name(repository_name)
            foreign_keys  = parent.key.map { |key| property_to_column_name(parent.repository(repository_name), key, false) } * ', '
            keys          = relationship.child_key.map { |key| property_to_column_name(model.repository(repository_name), key, false) } * ', '
            "ALTER TABLE #{quote_table_name(model.storage_name(repository_name))}
             ADD CONSTRAINT #{relationship.name}_fk FOREIGN KEY (#{keys}) REFERENCES #{foreign_table} (#{foreign_keys})"
          end
        end

        def destroy_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            if constraint_exists?(model.storage_name, "#{relationship.name}_fk")
              foreign_table = relationship.parent_model.storage_name(repository_name)
              "ALTER TABLE #{quote_table_name(model.storage_name(repository_name))} 
               DROP CONSTRAINT #{relationship.name}_fk"
            end
          end.compact
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