module DataMapper
  module Resource
    def adjust(attributes = {}, reload = false)
      raise NotImplementedError, 'adjust *with* validations has not be written yet, try adjust!'
    end

    def adjust!(attributes = {}, reload = false)
      return true if attributes.empty?

      adjust_attributes = {}

      model.properties(repository.name).values_at(*attributes.keys).each do |property|
        adjust_attributes[property] = attributes[property.name] if property
      end

      repository.adapter.adjust(adjust_attributes, query)

      collection.reload(:fields => adjust_attributes.keys) if reload

      true
    end
  end # Resource
end # DataMapper
