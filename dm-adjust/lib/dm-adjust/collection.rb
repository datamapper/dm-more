module DataMapper
  class Collection

    def adjust(attributes = {}, reload = false)
      raise NotImplementedError, 'adjust *with* validations has not be written yet, try adjust!'
    end

    ##
    # increment or decrement attributes on a collection
    #
    # @example [Usage]
    #   * People.all.adjust(:salary => +1000)
    #   * Children.all(:age.gte => 18).adjust(:allowance => -100)
    #
    # @param attributes <Hash> A hash of attributes to adjust, and their adjustment
    # @param reload <FalseClass,TrueClass> If true, affected objects will be reloaded
    #
    # @public
    def adjust!(attributes = {}, reload = false)
      return true if attributes.empty?

      reload_conditions = if reload
        model_key = model.key(repository.name)
        Query.target_conditions(self, model_key, model_key)
      end

      adjust_attributes = adjust_attributes(attributes)
      repository.adjust(adjust_attributes, self)

      if reload_conditions
        @query.clear
        @query.update(:conditions => reload_conditions)
        self.reload
      end

      true
    end

    private

    def adjust_attributes(attributes)
      adjust_attributes = {}

      model.properties(repository.name).values_at(*attributes.keys).each do |property|
        adjust_attributes[property] = attributes[property.name]
      end

      adjust_attributes
    end
  end # Collection
end # DataMapper
