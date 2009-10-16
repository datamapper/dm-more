module DataMapper
  module Resource
    def adjust(attributes = {}, reload = false)
      collection_for_self.adjust(*args)
    end

    def adjust!(*args)
      collection_for_self.adjust!(*args)
    end

    private

    def adjust_attributes(attributes)
      adjust_attributes = {}

      model.properties(repository.name).values_at(*attributes.keys).each do |property|
        adjust_attributes[property] = attributes[property.name]
      end

      adjust_attributes
    end
  end # Resource
end # DataMapper
