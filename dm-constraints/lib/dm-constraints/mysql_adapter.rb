module DataMapper
  module Constraints
    module MysqlAdapter
      module SQL

        def destroy_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            if constraint_exists?(model.storage_name, "#{relationship.name}_fk")
              foreign_table = relationship.parent_model.storage_name(repository_name)
              "ALTER TABLE #{quote_table_name(model.storage_name(repository_name))}
              DROP FOREIGN KEY #{relationship.name}_fk"
            end
          end.compact
        end

        def constraint_exists?(storage_name, constraint_name)
          statement = <<-EOS.compress_lines
            SELECT COUNT(*)
            FROM #{quote_table_name('information_schema')}.#{quote_table_name('table_constraints')}
            WHERE #{quote_column_name('table_schema')} = ?
              AND #{quote_column_name('table_name')} = ?
              AND #{quote_column_name('constraint_name')} = ?
          EOS
          query(statement, db_name, storage_name, constraint_name).first > 0
        end
      end
    end
  end
end