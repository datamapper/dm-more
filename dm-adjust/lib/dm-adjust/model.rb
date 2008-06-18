module DataMapper
  module Model

    ##
    # increment or decrement attributes on all objects in a resource
    #
    # @example [Usage]
    #   * People.adjust(:salary => +1000)
    #   * Children.adjust(:allowance => -100)
    #
    # @param attributes <Hash> A hash of attributes to adjust, and their adjustment
    # @public
    def adjust(attributes)
      all.adjust(attributes,false)
    end
  end
end
