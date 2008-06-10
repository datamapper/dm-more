module DataMapper
  module Is
    module NestedSet
      
      ##
      # Include the GeneratorMethods now. Wait with the other methods until
      # plugin is actually called (to keep from cluttering namespace)
      #

      ##
      # docs in the works
      #
      def is_nested_set(options={})
        options = { :child_key => :parent_id }.merge(options)

        extend  DataMapper::Is::NestedSet::ClassMethods
        include DataMapper::Is::NestedSet::InstanceMethods

        property :lft, Integer, :writer => :private
        property :rgt, Integer, :writer => :private

        belongs_to :parent,  :class_name => self.name, :child_key => [ options[:child_key] ], :order => [:lft.asc]
        has n,     :children,:class_name => self.name, :child_key => [ options[:child_key] ], :order => [:lft.asc]

        before :create do
          # scenarios:
          # - user creates a new object and does not specify a parent
          # - user creates a new object with a direct reference to a parent
          # - user spawnes a new object, and then moves it to a position
          if !self.parent
            self.class.root ? self.move_without_saving(:into => self.class.root) : self.move_without_saving(:to => 1)
            # if this is actually root, it will not move a bit (as lft is already 1)
          elsif self.parent && !self.lft
            # user has set a parent before saving (and without moving it anywhere). just move into that, and continue
            # might be som problems here if the referenced parent is not saved.
            self.move_without_saving(:into => self.parent)
          end
        end

        before :update do
          # scenarios:
          # - user moves the object to a position
          # - user has changed the parent
          # - user has removed any reference to a parent
          # - user sets the parent_id to something, and then use #move before saving
          if (self.parent && !self.lft) || (self.parent != self.ancestor)
            # if the parent is set, we try to move this into that parent, otherwise move into root.
            self.parent ? self.move_without_saving(:into => self.parent) : self.move_without_saving(:into => self.class.root)
          end
        end

        ##
        # reloads the position-attributes on all loaded objects after saving.
        #
        after :save do
          #puts "Reloading positions of all items"
          #puts "#{self.inspect}right after saving\n: #{self.collection.inspect}\n\n" if self.id == 7
          self.class.reload_positions(self)
        end
      end
      
      def is_a_nested_set(*args)
        warn("'is_a_nested_set' is depreciated, use 'is :nested_set' instead.")
        is_nested_set(*args)
      end
      
      ##
      # all the ClassMethods. They do not get added before / unless calling is_a_nested_set
      # since we dont want to clutter your model unless you need it.
      #
      module ClassMethods

        ##
        # get the root of the tree. might be changed when support for multiple roots is added.
        #
        def root
          first(:order => [:lft.asc])
        end

        def leaves
          all(:conditions => ["rgt=lft+1"], :order => [:lft.asc])
        end

        def reload_positions(caller)
          # When reloading one object, it reloads all objects in the same collection. Therefore
          # we need to trace which objects has been reloaded, so that we don't reload the same
          # objects multiple times.
          
          reloaded_nodes = []

          repository.identity_map(self).each_pair do |key,obj|
            if !reloaded_nodes.include?(obj.key)
              obj.reload_position
              reloaded_nodes = reloaded_nodes | obj.collection.map{|o| o.key }
            end
          end
        end

        ##
        # rebuilds the parent/child relationships (parent_id) from nested set (left/right values)
        #
        def rebuild_tree_from_set
          all.each do |node|
            node.parent = node.ancestor
            node.save
          end
        end

        ##
        # rebuilds the nested set using parent/child relationships and a chosen order
        #
        def rebuild_set_from_tree(order=nil)
          # pending
        end

        def offset_nodes_in_set(offset,range) # :nodoc:
          self.query_set("lft=lft+(?), rgt=rgt+(?)","rgt BETWEEN ?",offset,offset,range)
        end

        def alter_gap_in_set(pos,addition,opr='>=') # :nodoc:
          #[:lft,:rgt].each{ |p| self.query_set("\#{p}=\#{p}+(?)","\#{p} \#{opr} ?",addition,pos)}
          self.query_set("rgt=rgt+(?)","rgt #{opr} ?",addition,pos)
          self.query_set("lft=lft+(?)","lft #{opr} ?",addition,pos)
        end

        def query_set(set,where,*pars) # :nodoc:
          query = %Q{UPDATE #{self.storage_name} SET #{set} WHERE #{where}}
          repository.adapter.execute(query,*pars)
        end
      end

      module InstanceMethods

        ##
        # reloads the left and right attributes for self. if #move did not use this, we'd get quite
        # peculiar results, and most likely corrupt the nested sets pretty fast.
        #
        def reload_position
          self.reload_attributes(:lft,:rgt)
        end

        ##
        # move self / node to a position in the set. position can _only_ be changed through this
        #
        # @example [Usage]
        #   * node.move :higher           # moves node higher unless it is at the top of parent
        #   * node.move :lower            # moves node lower unless it is at the bottom of parent
        #   * node.move :below => other   # moves this node below other resource in the set
        #   * node.move :into => other    # same as setting a parent-relationship
        #
        # @param vector <Symbol, Hash> A symbol, or a key-value pair that describes the requested movement
        #
        # @option :higher<Symbol> move node higher
        # @option :highest<Symbol> move node to the top of the list (within its parent)
        # @option :lower<Symbol> move node lower
        # @option :lowest<Symbol> move node to the bottom of the list (within its parent)
        # @option :indent<Symbol> move node into sibling above
        # @option :outdent<Symbol> move node out below its current parent
        # @option :into<Resource> move node into another node
        # @option :above<Resource> move node above other node
        # @option :below<Resource> move node below other node
        # @option :to<Integer> move node to a specific location in the nested set
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
        # @see move
        def move_without_saving(vector)
          if vector.is_a? Hash then action,object = vector.keys[0],vector.values[0] else action = vector end

          ##
          # checking what kind of movement has been requested, and calculate the new position node should move to
          #
          position = case action
            when :higher  then left_sibling  ? left_sibling.lft    : nil # : "already at the top"
            when :highest then ancestor      ? ancestor.lft+1      : nil # : "is root, or has no parent"
            when :lower   then right_sibling ? right_sibling.rgt+1 : nil # : "already at the bottom"
            when :lowest  then ancestor      ? ancestor.rgt        : nil # : "is root, or has no parent"
            when :indent  then left_sibling  ? left_sibling.rgt    : nil # : "cannot find a sibling to indent into"
            when :outdent then ancestor      ? ancestor.rgt+1      : nil # : "is root, or has no parent"
            when :into    then object        ? object.rgt          : nil # : "supply an object"
            when :above   then object        ? object.lft          : nil # : "supply an object"
            when :below   then object        ? object.rgt+1        : nil # : "supply an object"
            when :to      then object        ? object.to_i         : nil # : "supply a number"
          end

          ##
          # raising an error whenever it couldnt move seems a bit harsh. want to return self for nesting.
          # if anyone has a good idea about how it should react when it cant set a valid position,
          # don't hesitate to find me in #datamapper, or send me an email at sindre -a- identu -dot- no
          #
          # raise UnableToPositionError unless position.is_a?(Integer) && position > 0
          return false if !position || position < 1
          # if node is already in the requested position
          if self.lft == position || self.rgt == position - 1
            self.parent = self.ancestor # must set this again, because it might have been changed by the user before move.
            return false
          end

          ##
          # if this node is already positioned we need to move it, and close the gap it leaves behind etc
          # otherwise we only need to open a gap in the set, and smash that buggar in
          #
          if self.lft && self.rgt
            # raise exception if node is trying to move into one of its descendants (infinate loop, spacetime will warp)
            raise RecursiveNestingError if position > self.lft && position < self.rgt
            # find out how wide this node is, as we need to make a gap large enough for it to fit in
            gap = self.rgt - self.lft + 1
            # make a gap at position, that is as wide as this node
            self.class.alter_gap_in_set( position , gap )
            # adding this gap may have changed this node's position. reloading the attributes from the repository
            self.reload_position
            # offset this node (and all its descendants) to the right position
            self.class.offset_nodes_in_set( position - self.lft , self.lft..self.rgt)
            # close the gap this movement left behind. self.lft here is the old value, _not_ yet reloaded after offset
            self.class.alter_gap_in_set(self.lft,-gap,'>')
            # reloading the position to the new one. this is really not nececarry, as it gets done on save automatically
            self.reload_position
          else
            # make a gap where the new node can be inserted
            self.class.alter_gap_in_set( position , 2 )
            # set the position fields
            self.lft, self.rgt = position, position + 1
          end

          self.parent = self.ancestor

        end

        ##
        # get the level of this node, where 0 is root. temporary solution
        #
        # @return <Integer>
        def level
          ancestors.length
        end

        ##
        # check if this node is a leaf (does not have subnodes).
        # use this instead ofdescendants.empty?
        #
        # @par
        def leaf?
          rgt-lft == 1
        end

        ##
        # all methods for finding related nodes following
        ##

        ##
        # get all ancestors of this node, up to (and including) self
        #
        # @return <Collection>
        def self_and_ancestors
          self.class.all(:lft.lte => lft, :rgt.gte => rgt, :order => [:lft.asc])
        end

        ##
        # get all ancestors of this node
        #
        # @return <Collection> collection of all parents, with root as first item
        # @see #self_and_ancestors
        def ancestors
          self.class.all(:lft.lt => lft, :rgt.gt => rgt, :order => [:lft.asc])
          #self_and_ancestors.reject{|r| r.key == self.key } # because identitymap is not used in console
        end

        ##
        # get the parent of this node. Same as #parent, but finds it from lft/rgt instead of parent-key
        #
        # @return <Resource, NilClass> returns the parent-object, or nil if this is root/detached
        def ancestor
          ancestors.last
        end

        ##
        # get the root this node belongs to. this will atm always be the same as Resource.root, but has a
        # meaning when scoped sets is implemented
        #
        # @return <Resource, NilClass>
        def root
          ancestors.first
        end

        ##
        # get all descendants of this node, including self
        #
        # @return <Collection> flat collection, sorted according to nested_set positions
        def self_and_descendants
          self.class.all(:lft => lft..rgt, :order => [:lft.asc])
        end

        ##
        # get all descendants of this node
        #
        # @return <Collection> flat collection, sorted according to nested_set positions
        # @see #self_and_descendants
        def descendants
          self_and_descendants.reject{|r| r.key == self.key } # because identitymap is not used in console
        end

        ##
        # get all descendants of this node that does not have any children
        #
        # @return <Collection>
        def leaves
          self.class.all(:lft => (lft+1)..rgt, :conditions=>["rgt=lft+1"], :order => [:lft.asc])
        end

        ##
        # get all siblings of this node, and include self
        #
        # @return <Collection>
        def self_and_siblings
          parent_key = self.class.relationships(:default)[:parent].child_key #.to_a.first
          parent ? self.class.all(Hash[ *parent_key.zip(parent.key).flatten ]) : [self]
        end

        ##
        # get all siblings of this node
        #
        # @return <Collection>
        # @see #self_and_siblings
        def siblings
          self_and_siblings.reject{|r| r.key == self.key } # because identitymap is not used in console
        end

        ##
        # get sibling to the left of/above this node in the nested tree
        #
        # @return <Resource, NilClass> the resource to the left, or nil if self is leftmost
        # @see #self_and_siblings
        def left_sibling
          self_and_siblings.find  {|v| v.rgt == lft-1}
        end

        ##
        # get sibling to the right of/above this node in the nested tree
        #
        # @return <Resource, NilClass> the resource to the right, or nil if self is rightmost
        # @see #self_and_siblings
        def right_sibling
          self_and_siblings.find  {|v| v.lft == rgt+1}
        end

      end

      class UnableToPositionError < StandardError; end
      class RecursiveNestingError < StandardError; end

    end # NestedSet
  end # Is
end # DataMapper
