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
    def adjust(attributes={}, load=true)
      return true if attributes.empty?
      adjust_attributes = {}
      # Finding the actual properties to adjust
      model.properties(repository.name).slice(*attributes.keys).each do |property|
        adjust_attributes[property] = attributes[property.name] if property
      end
      
      # if none of the attributes that are adjusted is part of the collection-query
      # there is no need to load the collection (it will not change after adjustment)
      # special case if it is in a :conditions-statement. can check for that?
      lazy_load! if load && query.conditions.detect{|c| adjust_attributes.include?(c[1]) }
      
      if loaded?
        # Doesnt this make for lots if dirty objects that in reality is not dirty?
        each { |r| attributes.each_pair{|a,v| r.attribute_set(a,r.attribute_get(a) + v) } }
        
      elsif !repository.identity_map(model).empty?
        
        loaded_keys = {}
        # Get the keys for all models loaded in the identity-map.
        @key_properties.zip(repository.identity_map(model).keys.transpose) do |property,values|
          loaded_keys[property] = values
        end
        
        # Get keys of all objects that are loaded, _and_ will be changed. Save their keys 
        # (for reloading) this actually fires a select-query. These are the keys of all objects 
        # that will be affected, and are already loaded in the identity-map.
        # If this collection has no conditions, every object needs to be reloaded anyways. 
        keys_to_reload = query.conditions.empty? ? loaded_keys : all(loaded_keys.merge(:fields => @key_properties)).send(:keys)
       
      end
      
      # Asking the repository (adapter) to do its magic. 
      affected = repository.adjust(adjust_attributes,scoped_query)
      
      # Reload the objects that was preloaded _and_ affected, unless this collection is loaded
      model.all(keys_to_reload).reload(:fields => attributes.keys) if keys_to_reload && !keys_to_reload.empty?
      
      # if the user did not want to load the collection before adjusting (performance-reasons?)
      # something is now officially borked. Even though its not quite good enough, the least we
      # can do is update the query of our collection to follow the adjustments. We need to loop 
      # through all conditions of the query, and check if any of our adjusted attributes are 
      # involved. if so, they must be updated to reflect the changes.
      query.conditions.each do |c|
        if adjustment = adjust_attributes[c[1]]
          case c[2]
          when Numeric then c[2] += adjustment
          when Range   then c[2] = (c[2].first+adjustment)..(c[2].last+adjustment)
          end
        end
      end
      
      return affected
      
    end

  end
end
