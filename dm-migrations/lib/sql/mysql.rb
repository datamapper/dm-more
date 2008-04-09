require File.dirname(__FILE__) + '/table'

module SQL
  module Mysql
    def table_exists?(table_name)

    end

    def supports_schema_transactions?
      false
    end

    def drop_database
    end
  end
end
