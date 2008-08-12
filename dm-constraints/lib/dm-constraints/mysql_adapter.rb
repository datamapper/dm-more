module DataMapper
  module Constraints
    module MysqlAdapter
      module SQL
        private

        def destroy_constraints_statement(table_name, constraint_name)
          <<-EOS.compress_lines
            ALTER TABLE #{quote_table_name(table_name)}
            DROP FOREIGN KEY #{quote_constraint_name(constraint_name)}
          EOS
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
