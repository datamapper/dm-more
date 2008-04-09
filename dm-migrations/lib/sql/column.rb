module SQL

  class Column

    attr_accessor :name, :type, :not_null, :default_value, :primary_key

    def initialize(col_struct)
      @name, @type, @default_value, @primary_key = col_struct.name, col_struct.type, col_struct.dflt_value, col_struct.pk

      @not_null = col_struct.notnull == 0
    end

  end

end


