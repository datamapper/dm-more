module DataMapper
  module Is

    # = dm-is-list
    #
    # DataMapper plugin for creating and organizing lists.
    #
    # == Installation
    #
    # === Stable
    #
    # Install the +dm-more+ gem, which will by default install +dm-is-list+ and other required gems.
    #
    #   $ (sudo)? gem install dm-more
    #
    # === Edge
    #
    # Download or clone +dm-more+ from Github[http://github.com/datamapper/dm-more/].
    #
    #   $ cd /path/to/dm-more
    #
    #   $ rake install            # will install all the dm-more gems (some of which are required by dm-is-list)
    #
    #   # enter your password at the prompt, if required
    #   $ password ...
    #
    #
    # == Getting started
    #
    # First of all, for a better understanding of this gem, make sure you study the '<tt>dm-is-list/spec/integration/list_spec.rb</tt>' file.
    #
    # ----
    #
    # Require +dm-is-list+ in your app.
    #
    #   require 'dm-core'         # must be required first
    #   require 'dm-is-list'
    #
    #
    # Lets say we have a User class, and we want to give users the possibility of
    # having their own todo-lists.
    #
    #
    #   class User
    #     include DataMapper::Resource
    #
    #     property :id, Serial
    #     property :name, String
    #
    #     has n, :todos
    #   end
    #
    #   class Todo
    #     include DataMapper::Resource
    #
    #     property :id, Serial
    #     property :title, String
    #     property :done, DateTime
    #
    #     belongs_to :user
    #
    #     # here we define that this should be a list, scoped on :user_id
    #     is :list, :scope => [:user_id]
    #   end
    #
    # Once we have our Users and Lists, we might want to work with...
    #
    # == Movements of list items
    #
    # Any list item can be moved around <b>within the same list</b> easily through the <tt>move</tt> method.
    #
    #
    # === move( vector )
    #
    # There are number of convenient vectors that help you move items around within the list.
    #
    #  item = Todo.get(1)
    #  other = Todo.get(2)
    #
    #  item.move(:highest)          # moves to top of list.
    #  item.move(:lowest)           # moves to bottom of list.
    #  item.move(:top)              # moves to top of list.
    #  item.move(:bottom)           # moves to bottom of list.
    #  item.move(:up)               # moves one up (:higher and :up is the same) within the scope.
    #  item.move(:down)             # moves one up (:lower and :down is the same) within the scope.
    #  item.move(:to => position)   # moves item to a specific position.
    #  item.move(:above => other)   # moves item above the other item.*
    #  item.move(:below => other)   # moves item above the other item.*
    #
    #  # * won't move if the other item is in another scope. (should this be enabled?)
    #
    # The list will act as intelligently as possible and keep positions in a logical running order.
    #
    #
    # === move( Integer )
    #
    # <b>NOTE! VERY IMPORTANT!</b>
    #
    # If you set the position manually, and then save, <b>the list will NOT reorganize itself</b>.
    #
    #  item.position = 3      # setting position manually
    #  item.save              # the item will now have position 3, but the list may have two items with the same position.
    #
    #  # alternatively
    #  item.update(:position => 3)    # sets the position manually, but does not reorganize the list positions.
    #
    #
    # You should therefore <b>always use</b> the <tt>item.move(N)</tt> syntax instead.
    #
    #   item.move(3)          # does the same as above, but in one call AND *reorganizes* the list.
    #
    # <hr>
    #
    # <b>Hold On!</b>
    #
    # <tt>dm-is-list</tt> used to work with <tt>item.position = 1</tt> type syntax.  Why this change?
    #
    # The main reason behind this change was that the previous version of <tt>dm-is-list</tt> created a LOT of
    # extra SQL queries in order to support the manual updating of position, and as a result had a quite a few bugs/issues,
    # which have been fixed in this version.
    #
    # The other reason is that I couldn't work out how to keep the functionality without adding the extra queries. But perhaps you can ?
    #
    # <hr>
    #
    # See "<b>Batch Changing Positions</b>" below for information on how to change the positions on a whole list.
    #
    # == Movements between scopes
    #
    # When you move items between scopes, the list will try to work with your intentions.
    #
    #
    # Move the item from list to new list and add the item to the bottom of that list.
    #
    #  item.user_id               # => 1
    #  item.move_to_list(10)      # => the scope id ie User.get(10).id
    #
    #  # results in...
    #  item.user_id                 # => 10
    #  item.position                # => < bottom of the list >
    #
    #
    # Move the item from list to new list and add at the position given.
    #
    #  item.user_id                 # => 1
    #  item.move_to_list(10, 2)     # => the scope id ie User.get(10).id,  position => 2
    #
    #  # results in...
    #  item.user_id                 # => 10
    #  item.position                # => 2
    #
    #
    # == Batch Changing Positions
    #
    # A common scenario when working with lists is the sorting of a whole list via something like JQuery's sortable() functionality.
    # <br>
    # (Think re-arranging the order of Todo's according to priority or something similar)
    #
    #
    # === Optimum scenario
    #
    # The most SQL query efficient way of changing the positions is:
    #
    #
    #   sort_order = [5,4,3,2,1]              # list from AJAX request..
    #
    #   items = Todo.all(:user => @u1)        # loads all 5 items in the list
    #
    #   items.each{ |item| item.update(:position => sort_order.index(item.id) + 1) }   # remember the +1 since array's are indexed from 0
    #
    #
    # The above code will result in something like these queries.
    #
    #   # SELECT "id", "title", "position", "user_id" FROM "todos" WHERE "user_id" = 1 ORDER BY "position"
    #   # UPDATE "todos" SET "position" = 5 WHERE "id" = 1
    #   # UPDATE "todos" SET "position" = 4 WHERE "id" = 2
    #   # UPDATE "todos" SET "position" = 2 WHERE "id" = 4
    #   # UPDATE "todos" SET "position" = 1 WHERE "id" = 5
    #
    # <b>Remember!</b>  Your sort order list has to be the same length as the found items in the list, or your loop will fail.
    #
    #
    # === Wasteful scenario
    #
    # You can also use this version, but it will create upto <b>5 times as many SQL queries</b>. :(
    #
    #
    #   sort_order = ['5','4','3','2','1']    # list from AJAX request..
    #
    #   items = Todo.all(:user => @u1)        # loads all 5 items in the list
    #
    #   items.each{ |item| item.move(sort_order.index(item.id).to_i + 1) }   # remember the +1 since array's are indexed from 0
    #
    # The above code will result in something like these queries:
    #
    #   #  SELECT "id", "title", "position", "user_id" FROM "todos" WHERE "user_id" = 1 ORDER BY "position"
    #
    #   #  SELECT "id", "title", "position", "user_id" FROM "todos" WHERE "user_id" = 1 ORDER BY "position" DESC LIMIT 1
    #   #  SELECT "id" FROM "todos" WHERE "user_id" = 1 AND "id" IN (1, 2, 3, 4, 5) AND "position" BETWEEN 1 AND 5 ORDER BY "position"
    #   #  UPDATE "todos" SET "position" = "position" + -1 WHERE "user_id" = 1 AND "position" BETWEEN 1 AND 5
    #   #  SELECT "id", "position" FROM "todos" WHERE "id" IN (1, 2, 3, 4, 5) ORDER BY "id"
    #   #  UPDATE "todos" SET "position" = 5 WHERE "id" = 1
    #
    #   #  SELECT "id", "title", "position", "user_id" FROM "todos" WHERE "user_id" = 1 ORDER BY "position" DESC LIMIT 1
    #   #  SELECT "id" FROM "todos" WHERE "user_id" = 1 AND "id" IN (1, 2, 3, 4, 5) AND "position" BETWEEN 1 AND 4 ORDER BY "position"
    #   #  UPDATE "todos" SET "position" = "position" + -1 WHERE "user_id" = 1 AND "position" BETWEEN 1 AND 4
    #   #  SELECT "id", "position" FROM "todos" WHERE "id" IN (2, 3, 4, 5) ORDER BY "id"
    #   #  UPDATE "todos" SET "position" = 4 WHERE "id" = 2
    #
    #   #  ...
    #
    # As you can see it will also do the job, but will be more expensive.
    #
    #
    # == RTFM
    #
    # As I said above, for a better understanding of this gem/plugin, make sure you study the '<tt>dm-is-list/spec/integration/list_spec.rb</tt>' tests.
    #
    #
    # == Errors / Bugs
    #
    # If something is not behaving intuitively, it is a bug, and should be reported.
    # Report it here: http://datamapper.lighthouseapp.com/
    #

    module List

      ##
      # method for making your model a list.
      #  TODO:: this explanation is confusing. Need to translate into literal code
      #
      # it will define a :position property if it does not exist, so be sure to have a
      # position-column in your database (will be added automatically on auto_migrate)
      # if the column has a different name, simply make a :position-property and set a
      # custom :field
      #
      # @example [Usage]
      #   is :list  # put this in your model to make it act as a list.
      #   is :list, :scope => [:user_id] # you can also define scopes
      #   is :list, :scope => [:user_id, :context_id] # also works with multiple params
      #
      # @param options <Hash> a hash of options
      #
      # @option :scope<Array> an array of attributes that should be used to scope lists
      #
      # @api public
      def is_list(options={})
        options = { :scope => [], :first => 1 }.merge(options)

        extend  DataMapper::Is::List::ClassMethods
        include DataMapper::Is::List::InstanceMethods

        unless properties.any? { |p| p.name == :position && p.type == Integer }
          property :position, Integer
        end

        @list_options = options

        before :create do
          # if a position has been set before save, then insert it at the position and
          # move the other items in the list accordingly, else if no position has been set
          # then set position to bottom of list
          send(:move_without_saving, position || :lowest)

          # on create, set moved to false so we can move the list item after creating it
          # self.moved = false
        end

        before :update do
          # a (new) position has been set => move item to this position (only if position has been set manually)
          # the scope has changed => detach from old list, and possibly move into position
          # the scope and position has changed => detach from old, move to pos in new

          # if the scope has changed, we need to detach our item from the old list
          if list_scope != original_list_scope
            newpos = position
            detach(original_list_scope) # removing from old list
            send(:move_without_saving, newpos || :lowest) # moving to pos or bottom of new list
          end

          #  NOTE:: uncommenting the following creates a large number of extra un-wanted SQL queries
          #  hence the commenting out of it.
          # if attribute_dirty?(:position) && !moved
          #   send(:move_without_saving, position)
          # end
          # # on update, clean moved to prepare for the next change
          # self.moved = false
        end

        before :destroy do
          detach
        end

        # we need to make sure that STI-models will inherit the list_scope.
        after_class_method :inherited do |retval, target|
          target.instance_variable_set(:@list_options, @list_options.dup)
        end

      end # is_list

      module ClassMethods
        attr_reader :list_options

        ##
        # use this function to repair / build your lists.
        #
        # @example [Usage]
        #   MyModel.repair_list # repairs the list, given that lists are not scoped
        #   MyModel.repair_list(:user_id => 1) # fixes the list for user 1, given that the scope is [:user_id]
        #
        # @param scope [Hash]
        #
        # @api public
        def repair_list(scope = {})
          return false unless scope.keys.all?{ |s| list_options[:scope].include?(s) || s == :order }
          all({ :order => [ :position ] }.merge(scope)).each_with_index{ |item, i| item.update(:position => i + 1) }
          true
        end

      end

      module InstanceMethods

        # @api semipublic
        attr_accessor :moved

        ##
        # returns the scope of the current list item
        #
        # @return <Hash> ...?
        #
        # @example [Usage]
        #   Todo.get(2).list_scope => { :user_id => 1 }
        #
        #
        # @api semipublic
        def list_scope
          model.list_options[:scope].map{ |p| [ p, attribute_get(p) ] }.to_hash
        end

        ##
        # returns the _original_ scope of the current list item
        #
        # @return <Hash> ...?
        #
        # @example [Usage]
        #   item = Todo.get(2) # with user_id 1
        #   item.user_id = 2
        #   item.original_list_scope  => { :user_id => 1 }
        #
        # @api semipublic
        def original_list_scope
          model.list_options[:scope].map{
            |p| [ p, (property = properties[p]) && original_attributes.key?(property) ? original_attributes[property] : attribute_get(p) ]
          }.to_hash
        end

        ##
        # returns the query conditions
        #
        # @return <Hash> ...?
        #
        # @example [Usage]
        #   Todo.get(2).list_query => { :user_id => 1, :order => [:position] }
        #
        # @api semipublic
        def list_query
          list_scope.merge(:order => [ :position ])
        end

        ##
        # returns the list the current item belongs to
        #
        # @param scope <Hash> Optional (Default is #list_query)
        #
        # @return <DataMapper::Collection> the list items within the given scope
        #
        # @example [Usage]
        #   Todo.get(2).list  => [ list of Todo items within the same scope as item]
        #   Todo.get(2).list(:user_id => 2 )  => [ list of Todo items with user_id => 2]
        #
        # @api public
        def list(scope = list_query)
          model.all(scope)
        end

        ##
        # repair the list this item belongs to
        #
        # @api public
        def repair_list
          model.repair_list(list_scope)
        end

        ##
        # reorder the list this item belongs to
        #
        # @param order <Array> ...?
        #
        # @return <Boolean> True/False based upon result
        #
        # @example [Usage]
        #   Todo.get(2).reorder_list([:title.asc])
        #
        # @api public
        def reorder_list(order)
          model.repair_list(list_scope.merge(:order => order))
        end

        ##
        # detaches a list item from the list, essentially setting the position as nil
        #
        # @param scope <Hash> Optional  (Default is #list_scope)
        #
        # @return <DataMapper::Collection> the list items within the given scope
        #
        # @example [Usage]
        #
        # @api public
        def detach(scope = list_scope)
          list(scope).all(:position.gt => position).adjust!({ :position => -1 },true)
          self.position = nil
        end

        ##
        # moves an item from one list to another
        #
        # @param scope <Integer> must be the id value of the scope
        # @param pos <Integer> Optional sets the entry position for the item in the new list
        #
        # @example [Usage]
        #   Todo.get(2).move_to_list(2)
        #   Todo.get(2).move_to_list(2, 10)
        #
        # @return <Boolean> True/False based upon result
        #
        # @api public
        def move_to_list(scope, pos = nil)
          transaction do |txn|
            self.detach   # remove from current list
            self.attribute_set(model.list_options[:scope][0], scope.to_i) # set new scope
            self.save     # save progress. Needed to get the positions correct.
            self.reload   # get a fresh new start
            self.move(pos) unless pos.nil?
          end
        end

        ##
        # finds the previous _higher_ item in the list (lower in number position)
        #
        # @return <Model> the previous list item
        #
        # @example [Usage]
        #   Todo.get(2).left_sibling  => Todo.get(1)
        #   Todo.get(2).higher_item  => Todo.get(1)
        #   Todo.get(2).previous_item  => Todo.get(1)
        #
        # @api public
        def left_sibling
          list.reverse.first(:position.lt => position)
        end
        alias_method :higher_item, :left_sibling
        alias_method :previous_item, :left_sibling

        ##
        # finds the next _lower_ item in the list (higher in number position)
        #
        # @return <Model> the next list item
        #
        # @example [Usage]
        #   Todo.get(2).right_sibling  => Todo.get(3)
        #   Todo.get(2).lower_item  => Todo.get(3)
        #   Todo.get(2).next_item  => Todo.get(3)
        #
        # @api public
        def right_sibling
          list.first(:position.gt => position)
        end
        alias_method :lower_item, :right_sibling
        alias_method :next_item, :right_sibling


        ##
        # move item to a position in the list. position should _only_ be changed through this
        #
        # @example [Usage]
        #   * node.move :higher                 # moves node higher unless it is at the top of list
        #   * node.move :lower                  # moves node lower unless it is at the bottom of list
        #   * node.move :below => other_node    # moves this node below the other resource in the list
        #   * node.move :above => Node.get(2)   # moves this node above the other resource in the list
        #   * node.move :to => 2                # moves this node to the position given in the list
        #   * node.move(2)                      # moves this node to the position given in the list
        #
        # @param vector <Symbol, Hash, Integer> An integer, a symbol, or a key-value pair that describes the requested movement
        #
        # @option :higher<Symbol> move item higher
        # @option :lower<Symbol> move item lower
        # @option :up<Symbol> move item higher
        # @option :down<Symbol> move item lower
        # @option :highest<Symbol> move item to the top of the list
        # @option :lowest<Symbol> move item to the bottom of the list
        # @option :top<Symbol> move item to the top of the list
        # @option :bottom<Symbol> move item to the bottom of the list
        # @option :above<Resource> move item above other item. must be in same scope
        # @option :below<Resource> move item below other item. must be in same scope
        # @option :to<Hash{Symbol => Integer/String}> move item to a specific position in the list
        # @option <Integer> move item to a specific position in the list
        #
        # @return <TrueClass, FalseClass> returns false if it cannot move to the position, otherwise true
        # @see move_without_saving
        #
        # @api public
        def move(vector)
          transaction do |txn|
            move_without_saving(vector) && save
          end
        end


        private

          ##
          # does all the actual movement in #move, but does not save afterwards. this is used internally in
          # before :create / :update. Should not be used by organic beings.
          #
          # @see move
          #
          # @api private
          def move_without_saving(vector)
            if vector.kind_of?(Hash)
              action, object = vector.keys[0], vector.values[0]
            else
              action = vector
            end

            # set the start position to 1 or, if offset in the list_options is :list, :first => X
            minpos = model.list_options[:first]

            # the previous position (if changed) else current position
            prepos = original_attributes[properties[:position]] || position

            # set the last position in the list or previous position if the last item
            maxpos = (last = list.last) ? (last == self ? prepos : last.position + 1) : minpos

            newpos = case action
              when :highest     then minpos
              when :top         then minpos
              when :lowest      then maxpos
              when :bottom      then maxpos
              when :higher,:up  then [ position - 1, minpos ].max
              when :lower,:down then [ position + 1, maxpos ].min
              when :above
                # the object given, can either be:
                # -- the same as self
                # -- already below self
                # -- higher up than self (lower number in list)
                ( (self == object) or (object.position > self.position) ) ? self.position : object.position

              when :below
                # the object given, can either be:
                # -- the same as self
                # -- already above self
                # -- lower than self (higher number in list)
                ( self == object or (object.position < self.position) ) ? self.position : object.position + 1

              when :to
                # can only move within top and bottom positions of list
                # -- .move(:to => 2 ) Hash with FixNum
                # -- .move(:to => '2' ) Hash with String

                # NOTE:: sensitive functionality
                # maxpos is incremented above, so decrement by 1 to get true maxpos
                # minpos is fixed, so just take the object position value given
                # else add 1 to object position value
                obj = object.to_i
                if (obj > maxpos)
                  [ minpos, [ obj, maxpos - 1 ].min ].max
                else
                  [ minpos, [ obj, maxpos ].min ].max
                end

              else
                raise ArgumentError, "unrecognized vector: [#{action}]. Please check your spelling and/or the docs" if action.is_a?(Symbol)
                # -- .move(2) as FixNum only
                # -- .move('2') as String only
                if action.to_i < minpos
                  [ minpos, maxpos - 1 ].min
                else
                  [ action.to_i, maxpos - 1 ].min
                end
            end

            # don't move if already at the position
            return false if [ :lower, :down, :higher, :up, :top, :bottom, :highest, :lowest, :above, :below ].include?(action) && newpos == prepos
            return false if !newpos || ([ :above, :below ].include?(action) && list_scope != object.list_scope)
            return true  if newpos == position && position == prepos || (newpos == maxpos && position == maxpos - 1)

            if !position
              list.all(:position.gte => newpos).adjust!({ :position => 1 }, true) unless action =~ /:(lowest|bottom)/
            elsif newpos > prepos
              newpos -= 1 if [:lowest,:bottom,:above,:below].include?(action)
              list.all(:position => prepos..newpos).adjust!({ :position => -1 }, true)
            elsif newpos < prepos
              list.all(:position => newpos..prepos).adjust!({ :position => 1  }, true)
            end

            self.position = newpos
            self.moved = true
            true
          end # move_without_saving

      end # InstanceMethods
    end # List
  end # Is
end # DataMapper
