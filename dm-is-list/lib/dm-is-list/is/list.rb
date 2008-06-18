module DataMapper
  module Is
    module List

      ##
      #
      #
      def is_list(options={})
        defaults = {:property => :position, :scope => [] }

        options = defaults.merge(options)

        extend  DataMapper::Is::List::ClassMethods
        include DataMapper::Is::List::InstanceMethods

        property :position, Integer, :lock => true

        before :create do
          # insert at bottom of list, unless position is specified. If its specified, move silently

          if self.position
            # flytt den til denne posisjonen (dvs rydd vei, flytt inn, og trekk sammen)
            # skal egentlig bruke 'insert' siden den ikke har vært plassert noe sted før.
            self.move_without_saving(:to => self.position)
          else
            # hvis ikke, sett posisjonen til den neste i rekken (innenfor dette scope)
            self.position = self.class.next_position_in_list(self)
          end
        end
      end

      module ClassMethods
        def next_position_in_list(for_scope)
          (max(:position)||0)+1 # add scope here
        end
      end
      
      module InstanceMethods
        
        def list_scope
          
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
          maxpos = self.class.next_position_in_list(self)
            
          newpos = case action
            when :highest then 1
            when :lowest  then maxpos
            when :higher  then position-1
            when :lower   then position+1
            when :above   then object.position
            when :below   then object.position-1
            when :to      then object.to_i
          end
          
          return false if !newpos || newpos < 1 || newpos == position || (newpos == maxpos && position == maxpos-1)
          
          if newpos > position
            newpos -= 1 if [:lowest,:above,:to].include?(action)
            self.class.all(:position => position..newpos).adjust(:position => -1)
          elsif newpos < position
            self.class.all(:position => newpos..position).adjust(:position => +1)
          end
          
          self.position = newpos

        end
        
        def siblings
          # all(@list_options[:scope])
        end
        
        def left_sibling
          self.class.first(:position.lt => position, :order => [:position.desc] ) # scope here
        end
        
        def right_sibling
          self.class.first(:position.gt => position, :order => [:position.asc] ) # scope here
        end
        
        def self_and_siblings
          self.class.all # scope here
        end
                
      end
      
      class UnableToPositionError < StandardError; end
      class RecursiveNestingError < StandardError; end
      
    end # List
  end # Is
end # DataMapper
