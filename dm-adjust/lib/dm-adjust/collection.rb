module DataMapper
  class Collection

    ##
    # increment or decrement attributes on a collection
    #
    # @example [Usage]
    #   * People.all.adjust(:salary => +1000)
    #   * Children.all(:age.gte => 18).adjust(:allowance => -100)
    #
    # @param attributes <Hash> A hash of attributes to adjust, and their adjustment
    # @param load <TrueClass,FalseClass>
    # @public
    def adjust(attributes={},preload=true)
      return true if attributes.empty?
      
      adjust_attributes,keys_to_reload = {},{}

      # Finding the actual properties to adjust
      model.properties(repository.name).slice(*attributes.keys).each do |property|
        adjust_attributes[property] = attributes[property.name] if property
      end

      # if none of the attributes that are adjusted is part of the collection-query
      # there is no need to load the collection (it will not change after adjustment)
      # if the query contains a raw sql-string, we cannot (truly) know, and must load.
      is_affected = !!query.conditions.detect{|c| adjust_attributes.include?(c[1]) || c[0] == :raw }

      lazy_load if preload && is_affected

      if loaded?
        # Doesnt this make for lots if dirty objects that in reality is not dirty?
        each { |r| attributes.each_pair{|a,v| r.attribute_set(a,r.send(a) + v) } }

      elsif !repository.identity_map(model).empty?
        # Get the keys for all models loaded in the identity-map.
        @key_properties.zip(repository.identity_map(model).keys.transpose) do |property,values|
          keys_to_reload[property] = values
        end
        
        # Get keys of all currently loaded objects that will be altered.
        # If the changed attributes don't interfere with our query, we don't need to prefetch anything.
        keys_to_reload = all(loaded_keys.merge(:fields => @key_properties)).send(:keys) if is_affected
      end

      # Asking the repository (adapter) to do its magic.
      repository.adjust(adjust_attributes,scoped_query)

      # Reload affected objects in identity-map. if collection was affected, dont use the scope.
      (is_affected ? model : self).all(keys_to_reload).reload(:fields => attributes.keys) unless keys_to_reload.empty?

      # if preload was set to false, and collection was affected by updates, 
      # something is now officially borked. We'll try the best we can (still many cases this is borked for)
      query.conditions.each do |c|
        if adjustment = adjust_attributes[c[1]]
          case c[2]
            when Numeric then c[2] += adjustment
            when Range   then c[2] = (c[2].first+adjustment)..(c[2].last+adjustment)
          end if adjustment = adjust_attributes[c[1]]
        end
      end if is_affected

      return true

    end # adjust
  end # Collection
end # DataMapper
