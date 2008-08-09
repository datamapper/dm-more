module DataMapper
  module Constraints
    module PostgresAdapter
      module SQL

        def constraint_exists?(storage_name, constraint_name)
          statement = <<-EOS.compress_lines
            SELECT COUNT(*)
            FROM "information_schema"."table_constraints"
            WHERE "table_schema" = current_schema()
              AND "table_name" = ?
              AND "constraint_name" = ?
          EOS
          query(statement, storage_name, constraint_name).first > 0
        end

      end
    end
  end
end