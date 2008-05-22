module DataMapper
  module Is
    module NestedSet
      def self.included(base)
        base.extend(ClassMethods)
        base.is_a_nested_set
        #raise NotImplementedError
      end
      
      module ClassMethods
        def is_a_nested_set(options={})

          property :lft, Integer
          property :rgt, Integer
          
          belongs_to :parent,  :class_name => self.name, :child_key => [ :parent_id ], :order => [:lft.asc]
          has n, :children,    :class_name => self.name, :child_key => [ :parent_id ], :order => [:lft.asc]
          
          include DataMapper::Is::NestedSet::InstanceMethods
          
          class_eval <<-CLASS, __FILE__, __LINE__
            def self.root
              first :order => [:lft.asc]
            end

            def self.leaves
              all(:order => [:lft.asc], :conditions => ["rgt = lft + 1"])
            end
          CLASS
          
        end
        
      end
      
      module InstanceMethods
        
        def ancestors
          self_and_ancestors.reject{|r| r==self } # self_and_ancestors - [self]
        end
        
        def self_and_ancestors
          self.class.all(:lft.lte => lft, :rgt.gte => rgt, :order => [:lft.asc])
        end
        
        def descendants
          self_and_descendants.reject{|r| r==self }
        end
        
        def self_and_descendants(options={})
          self.class.all(:lft => lft..rgt, :order => [:lft.asc])
        end

        def siblings
          self_and_siblings.reject{|r| r==self }
        end
        
        def self_and_siblings
          self.class.all(:parent_id => parent_id)
        end
        
        def leaves
          self.class.all(:lft => (lft+1)..rgt, :order => [:lft.asc], :conditions => ["rgt = lft + 1"])
        end
        
        def place_into(resource)
        
        end
        
        def place_above(resource)
        
        end
        
        def place_below(resource)
        
        end
      end # InstanceMethods
    end # NestedSet
  end # Is
end # DataMapper
