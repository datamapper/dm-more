module DataMapper
  module Is
    module List

      ##
      #
      #
      def is_list(options={})
        options = { :scope => [] }.merge(options)

        extend  DataMapper::Is::List::ClassMethods
        include DataMapper::Is::List::InstanceMethods
        
        property :position, Integer unless properties.detect{|p| p.name == :position && p.type == Integer}

        @list_scope = options[:scope]


        before :save do
          if new_record?
            # a position has been set before save => open up and make room for item
            # no position has been set => move to bottom of my scope-list (or keep detached?)
            self.position ? self.move_without_saving(:to => self.position) : self.move_without_saving(:lowest)
          else
            # a (new) position has been set => move item to this position (only if position has been set manually)
            # the scope has changed => detach from old list, and possibly move into position
            # the scope and position has changed => detach from old, move to pos in new
          end
        end
      end

      module ClassMethods
        attr_reader :list_scope, :list_property
      end
      
      module InstanceMethods

        def list_scope
          self.class.list_scope
        end
        
        def list_query
          Hash[ :order, [:position.asc],*list_scope.zip(attributes.values_at(*list_scope)).flatten ]
        end

        ##
        # move item to a position in the list. position should _only_ be changed through this
        #
        # @example [Usage]
        #   * node.move :higher           # moves node higher unless it is at the top of parent
        #   * node.move :lower            # moves node lower unless it is at the bottom of parent
        #   * node.move :below => other   # moves this node below other resource in the set
        #
        # @param vector <Symbol, Hash> A symbol, or a key-value pair that describes the requested movement
        #   
        # @option :higher<Symbol> move item higher
        # @option :highest<Symbol> move item to the top of the list
        # @option :lower<Symbol> move item lower
        # @option :lowest<Symbol> move item to the bottom of the list
        # @option :above<Resource> move item above other item. must be in same scope
        # @option :below<Resource> move item below other item. must be in same scope
        # @option :to<Fixnum> move item to a specific location in the list
        #
        # @return <FalseClass> returns false if it cannot move to the position, or if it is already there
        # @raise <RecursiveNestingError> if node is asked to position itself into one of its descendants
        # @raise <UnableToPositionError> if node is unable to calculate a new position for the element
        # @see move_without_saving
        def move(vector)
          move_without_saving(vector)
          save
        end
        
        ##
        # does all the actual movement in #move, but does not save afterwards. this is used internally in
        # before :save, and will probably be marked private. should not be used by organic beings.
        #
        # @see move_without_saving 
        def move_without_saving(vector)
          if vector.is_a? Hash then action,object = vector.keys[0],vector.values[0] else action = vector end

          # 1. find the new position to move into
          # 2. get the old position (if any)
          # 3. open a gap for the new position (but don't leave one where we have removed one)
          # 4. insert / move this item (set the new position with position=...)
          
          # should all this happen when someone does move(:higher)? I don't really think the action should happen just yet?
          # can have a move! function to go instead, where it actually saves..
          #alias offset self.class.offset_items_in_list # can I reference a function like this?
          maxpos = list.last ? list.last.position + 1 : 1
            
          newpos = case action
            when :highest then 1
            when :lowest  then maxpos
            when :higher  then position-1
            when :lower   then position+1
            when :above   then object.position
            when :below   then object.position+1
            when :to      then object.to_i
          end
          
          return false if !newpos || newpos < 1 || newpos == position || (newpos == maxpos && position == maxpos-1)
          
          if !position
            
          elsif newpos > position
            newpos -= 1 if [:lowest,:above,:below,:to].include?(action)
            self.class.all(list_query).all(:position => position..newpos).adjust(:position => -1)
          elsif newpos < position
            self.class.all(list_query).all(:position => newpos..position).adjust(:position => +1)
          end
          
          self.position = newpos

        end
        
        def detach(scope=list_query)
          self.class.all(scope).all(:position.gt => position).adjust(:position => -1)
          position = nil
        end
                
        def left_sibling
          self.class.all(list_query).first(:position.lt => position, :order => [:position.desc]) # scope here
        end
        
        def right_sibling
          self.class.all(list_query).first(:position.gt => position, :order => [:position.asc] ) # scope here
        end
        
        def self_and_siblings
          self.class.all(list_query)
        end
        alias_method :list, :self_and_siblings
                
      end
      
      class UnableToPositionError < StandardError; end
      class RecursiveNestingError < StandardError; end
      
    end # List
  end # Is
end # DataMapper
