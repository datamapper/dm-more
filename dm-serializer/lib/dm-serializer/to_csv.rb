require 'dm-serializer/common'

if RUBY_VERSION >= '1.9.0'
 require 'csv'
else
  begin
    gem 'fastercsv', '~>1.5.0'
    require 'fastercsv'
    CSV = FasterCSV
  rescue LoadError
    # do nothing
  end
end

module DataMapper
  module Serialize
    # Serialize a Resource to comma-separated values (CSV).
    #
    # @return <String> a CSV representation of the Resource
    def to_csv(writer = '')
      CSV.generate(writer) do |csv|
        row = model.properties(repository.name).map do |property|
          __send__(property.name).to_s
        end
        csv << row
      end
    end
  end

  class Collection
    def to_csv
      result = ''
      each do |item|
        result << item.to_csv + "\n"
      end
      result
    end
  end

  if Serialize::Support.dm_validations_loaded?

    module Validate
      class ValidationErrors
        def to_csv(writer = '')
          CSV.generate(writer) do |csv|
            errors.each do |key, value|
              value.each do |error|
                row = []
                row << key.to_s
                row << error.to_s
                csv << row
              end
            end
          end
        end
      end
    end

  end

end
