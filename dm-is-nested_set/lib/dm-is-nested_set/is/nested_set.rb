module DataMapper
  module Is
    module NestedSet
      def self.included(base)
        base.extend(ClassMethods)
        #raise NotImplementedError
      end
      
      module ClassMethods
        
        ##
        # docs in the works
        #
        def is_a_nested_set(options={})
          options = { :child_key => :parent_id }.merge(options)

          include DataMapper::Is::NestedSet::InstanceMethods
          
          property :lft, Integer, :writer => :private
          property :rgt, Integer, :writer => :private
          
          belongs_to :parent,  :class_name => self.name, :child_key => [ options[:child_key] ], :order => [:lft.asc]
          has n,     :children,:class_name => self.name, :child_key => [ options[:child_key] ], :order => [:lft.asc]
          
          ##
          # demands that the node has a position in the tree, and moves it into the right position if parent-association
          # has been changed manually by the user
          #
          before :save do 
            if self.class.count == 0
              self.lft , self.rgt = 1 , 2
            elsif self.new_record? && !self.parent && !self.attribute_dirty?(:lft) 
              self.move(:into => self.class.root); throw :halt
            elsif self.parent && self.attribute_dirty?(options[:child_key]) && !self.attribute_dirty?(:lft) 
              self.move(:into => self.parent); throw :halt
            end 
          end
          
          ##
          # reloads the position-attributes on all loaded objects after saving. left / right will often get changed
          # by semimanual queries, and this is a way to try to keep the objects up with the changes with minimal
          # performance loss
          #
          after :save do
            self.class.reload_positions
          end
          
          ##
          # makes sure that all finders order correctly. if overridden (on class-level),some of the nested-set finders may act up
          #
          scope_stack << Query.new(repository,self,:order => [:lft.asc])
          
          class_eval <<-CLASS, __FILE__, __LINE__
            
            def self.root
              first
            end
            
            def self.leaves
              all(:conditions => ["rgt=lft+1"])
            end
            
            def self.reload_positions
              repository.identity_map_get(self).each_pair{ |key,obj| obj.reload_position }
            end
              
            def self.query_set(set,where,*pars)
              query = %Q{UPDATE \#{self.storage_name} SET \#{set} WHERE \#{where}}
              repository.adapter.execute(query,*pars)
            end
            
            def self.alter_gap_in_set(pos,addition,opr='>=')
              #[:lft,:rgt].each{ |p| self.query_set("\#{p}=\#{p}+(?)","\#{p} \#{opr} ?",addition,pos)}
              self.query_set("rgt=rgt+(?)","rgt \#{opr} ?",addition,pos)
              self.query_set("lft=lft+(?)","lft \#{opr} ?",addition,pos)
            end
            
            def self.offset_nodes_in_set(offset,range)
              self.query_set("lft=lft+(?), rgt=rgt+(?)","rgt BETWEEN ?",offset,offset,range)
            end
          CLASS
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
        # @option :higher<Symbol> move node higher (1 up if possible) # specifying nr of steps is in the pipeline
        # @option :highest<Symbol> move node to the top of the list (within its parent)
        # @option :lower<Symbol> move node lower (1 down if possible)
        # @option :lowest<Symbol> move node to the bottom of the list (within its parent)
        # @option :indent<Symbol> move node into sibling above
        # @option :outdent<Symbol> move node out below its current parent
        # @option :into<Resource> move node into another node
        # @option :above<Resource> move node above other node 
        # @option :below<Resource> move node below other node
        # @option :to<Fixnum> move node to a specific location in the nested set
        #
        # @return <FalseClass> returns false if it cannot move to the position, or if it is already there
        # @raise <RecursiveNestingError> if node is asked to position itself into one of its descendants
        # @raise <UnableToPositionError> if node is unable to calculate a new position for the element
        def move(vector)
          if vector.is_a? Hash then action,obj = vector.keys[0],vector.values[0] else action = vector end
          
          ##
          # checking what kind of movement has been requested, and calculate the new position node should move to
          #
          position = case action
            when :higher  then left_sibling.lft   if left_sibling
            when :highest then ancestor.lft+1     if ancestor
            when :lower   then right_sibling.lft  if right_sibling
            when :lowest  then ancestor.rgt       if ancestor
            when :indent  then left_sibling.rgt   if left_sibling
            when :outdent then ancestor.rgt+1     if ancestor
            when :into    then obj.rgt            if obj
            when :above   then obj.lft            if obj
            when :below   then obj.rgt+1          if obj
            when :to      then obj.to_i           if obj
          end
          
          raise UnableToPositionError unless position > 0 && position.is_a?(Fixnum)
          
          ##
          # if this node is already positioned we need to move it, and close the gap it leaves behind etc
          # otherwise we only need to open a gap in the set, and smash that buggar in
          # 
          if self.lft && self.rgt
            return false if self.lft == position || self.rgt == position - 1
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

          # after repositioning we try to set the parent according to the structure of the nested set, _not_ the parent_id
          self.parent = self.ancestor
          # saving the node, since parent and positions may have changed
          self.save
        end
        
        ##
        # get the level of this node, where 0 is root. temporary solution
        # 
        # @return <Fixnum>
        def level
          ancestors.length
        end
        
        ##
        # get all ancestors of this node, up to (and including) self
        # 
        # @return <Collection> Returns
        def self_and_ancestors
          self.class.all(:lft.lte => lft, :rgt.gte => rgt)
        end
        
        ##
        # get all ancestors of this node
        # 
        # @return <Collection> collection of all parents, with root as first item
        # @see #self_and_ancestors
        def ancestors
          self_and_ancestors.reject{|r| r == self }
        end
        
        ##
        # get the parent of this node. Same as #parent, but finds it from lft/rgt instead of parent-key
        #
        # @return <Resource, NilClass> returns the parent-object, or nil if this is root/detached
        def ancestor
          ancestors.reverse.first
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
          self.class.all(:lft => lft..rgt)
        end
        
        ##
        # get all descendants of this node
        #
        # @return <Collection> flat collection, sorted according to nested_set positions
        # @see #self_and_descendants
        def descendants
          self_and_descendants.reject{|r| r == self }
        end
        
        ##
        # get all descendants of this node that does not have any children
        #
        # @return <Collection>
        def leaves
          self.class.all(:lft => (lft+1)..rgt, :conditions=>["rgt=lft+1"])
        end
        
        ##
        # get all siblings of this node, and include self 
        #
        # @return <Collection>
        def self_and_siblings
          self.class.all(:parent_id => parent_id)
        end
        
        ##
        # get all siblings of this node
        #
        # @return <Collection>
        # @see #self_and_siblings
        def siblings
          self_and_siblings.reject{|r| r == self }
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
