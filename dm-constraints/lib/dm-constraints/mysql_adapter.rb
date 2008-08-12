module DataMapper
  module Constraints
    module MysqlAdapter
      module SQL

        def destroy_constraints_statements(repository_name, model)
          model.many_to_one_relationships.map do |relationship|
            table_name      = model.storage_name(repository_name)
            constraint_name = constraint_name(table_name, relationship.name)
            next unless constraint_exists?(model.storage_name, constraint_name)
            <<-EOS.compress_lines
              ALTER TABLE #{quote_table_name(table_name)}
              DROP FOREIGN KEY #{quote_constraint_name(constraint_name)}
            EOS
          end.compact
        end

        def constraint_exists?(storage_name, constraint_name)
          statement = <<-EOS.compress_lines
            SELECT COUNT(*)
            FROM `information_schema`.`table_constraints`
            WHERE `constraint_type` = 'FOREIGN KEY'
            AND `table_schema` = ?
            AND `table_name` = ?
            AND `constraint_name` = ?
          EOS
          query(statement, db_name, storage_name, constraint_name).first > 0
        end
      end
    end
  end
end
