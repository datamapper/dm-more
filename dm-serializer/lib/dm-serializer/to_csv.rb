require 'dm-serializer/common'

begin
  gem('fastercsv')
  require 'faster_csv'
rescue LoadError
  nil
end

module DataMapper
  module Serialize
    # Serialize a Resource to comma-separated values (CSV).
    #
    # @return <String> a CSV representation of the Resource
    def to_csv(writer = '')
      FasterCSV.generate(writer) do |csv|
        row = []
        self.class.properties(repository.name).each do |property|
         row << send(property.name).to_s
        end
        csv << row
      end
    end
  end

  class Collection
    def to_csv
      result = ""
      each do |item|
        result << item.to_csv + "\n"
      end
      result
    end
  end
end
