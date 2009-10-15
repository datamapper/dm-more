module DataMapper
  module Model

    def adjust(*args)
      all.adjust(*args)
    end

    ##
    # increment or decrement attributes on all objects in a resource
    #
    # @example [Usage]
    #   * People.adjust(:salary => +1000)
    #   * Children.adjust(:allowance => -100)
    #
    # @param attributes <Hash> A hash of attributes to adjust, and their adjustment
    # @public
    def adjust!(*args)
      all.adjust!(*args)
    end
  end # Model
end # DataMapper
