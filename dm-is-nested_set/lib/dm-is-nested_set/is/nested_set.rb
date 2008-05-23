module DataMapper
  module Is
    module NestedSet
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def is_a_nested_set(options={})
          options = { :child_key => :parent_id }.merge(options)

          include DataMapper::Is::NestedSet::InstanceMethods
          
          property :lft, Integer, :writer => :private
          property :rgt, Integer, :writer => :private
          
          belongs_to :parent,  :class_name => self.name, :child_key => [ options[:child_key] ], :order => [:lft.asc]
          has n,     :children,:class_name => self.name, :child_key => [ options[:child_key] ], :order => [:lft.asc]
        
          before :save do 
            if self.class.count == 0
              self.lft , self.rgt = 1 , 2
            elsif self.new_record? && !self.parent && !self.attribute_dirty?(:lft) 
              self.move(:into => self.class.root); throw :halt
            elsif self.parent && self.attribute_dirty?(options[:child_key]) && !self.attribute_dirty?(:lft) 
              self.move(:into => self.parent); throw :halt
            end 
          end
          
          after :save do
            self.class.reload_positions
          end
          
          scope_stack << Query.new(repository,self,:order => [:lft.asc])
          
          class_eval <<-CLASS, __FILE__, __LINE__
            def self.root;   first;                             end
            def self.leaves; all(:conditions => ["rgt=lft+1"]); end
            def self.reload_positions; repository.identity_map_get(self).each_pair{ |key,obj| obj.reload_position } end
              
            def self.query_set(set,where)
              query = %Q{ UPDATE categories SET \#{set} WHERE \#{where} }
              repository.adapter.execute query.gsub(/lft/,'lft').gsub(/rgt/,'rgt').gsub('+ -','-')
            end
            
            def self.alter_gap_in_set(pos,addition,operator='>=')
              self.query_set("rgt = rgt+\#{addition}" ,"rgt \#{operator} \#{pos}")
              self.query_set("lft = lft+\#{addition}", "lft \#{operator} \#{pos}")
            end
          CLASS
        end
      end # ClassMethods
      
      module InstanceMethods
        
        def reload_position; self.reload_attributes(:lft,:rgt) end
        
        #
        # Use to move node. Example:  object.move(:higher), object.move(:into => parent) 
        #
        def move(opts)
          if opts.is_a? Hash then action,obj = opts.keys[0],opts.values[0] else action = opts end
          
          position = case action
            when :higher then left_sibling.lft if left_sibling
            when :lower  then right_sibling.lft if right_sibling
            when :into   then obj.rgt
            when :above  then obj.lft
            when :below  then obj.rgt+1
            when :to     then obj
          end
          
          if self.rgt && self.lft
            return false if self.lft == position || self.rgt == position - 1 || position.blank? # If already in position
            gap = self.rgt - self.lft + 1 # How wide am I?
            self.class.alter_gap_in_set( position , gap ) # Making a gap where we can insert the node
            self.reload_position # Reloading my coordinates, in case I was skewed to the left
            distance = position - self.lft # Calculating my distance from the position I'm aiming for
            self.class.query_set("lft=lft + #{distance}, rgt=rgt + #{distance}", "rgt BETWEEN #{self.lft} AND #{self.rgt}" )
            self.class.alter_gap_in_set(self.lft,-gap,'>') # Closing the gap I left behind
            self.reload_position # Reloading my coordinates, in case I was skewed to the left
          elsif position
            self.class.alter_gap_in_set( position , 2 ) # Making a gap where we can insert the node
            self.lft, self.rgt = position, position + 1    # Setting the lft/rgt for my model
          end
          self.parent = self.ancestor
          self.save
        end
        
        #
        # Finders for retrieving different nodes in the set
        #
        def self_and_ancestors;   self.class.all(:lft.lte => lft, :rgt.gte => rgt)               end
        def ancestors;            self_and_ancestors.reject{|r| r == self }                      end
        def ancestor;             ancestors.reverse.first                                        end
        def self_and_descendants; self.class.all(:lft => lft..rgt)                               end
        def descendants;          self_and_descendants.reject{|r| r == self }                    end
        def self_and_siblings;    self.class.all(:parent_id => parent_id)                        end
        def siblings;             self_and_siblings.reject{|r| r == self }                       end
        def left_sibling;         self_and_siblings.find  {|v| v.rgt == lft-1}                   end
        def right_sibling;        self_and_siblings.find  {|v| v.lft == rgt+1}                   end
        def leaves;               self.class.all(:lft => lft..rgt, :conditions=>["rgt=lft+1"])   end
      end # InstanceMethods
    end # NestedSet
  end # Is
end # DataMapper
