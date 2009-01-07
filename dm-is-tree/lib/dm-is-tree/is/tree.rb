module DataMapper
  module Is
    module Tree
      def self.included(base)
        base.extend(ClassMethods)
      end

      # An extension to DataMapper to easily allow the creation of tree
      # structures from your DataMapper models.
      # This requires a foreign key property for your model, which by default
      # would be called :parent_id.
      #
      #   Example:
      #
      #   class Category
      #     include DataMapper::Resource
      #
      #     property :id, Integer
      #     property :parent_id, Integer
      #     property :name, String
      #
      #     is :tree, :order => "name"
      #   end
      #
      #   root
      #     +- child
      #          +- grandchild1
      #          +- grandchild2
      #
      #   root        = Category.create("name" => "root")
      #   child       = root.children.create("name" => "child")
      #   grandchild1 = child1.children.create("name" => "grandchild1")
      #   grandchild2 = child2.children.create("name" => "grandchild2")
      #
      #   root.parent   # => nil
      #   child.parent  # => root
      #   root.children # => [child]
      #   root.children.first.children.first # => grandchild1
      #   Category.first_root  # => root
      #   Category.roots       # => [root]
      #
      # The following instance methods are added:
      # * <tt>children</tt> - Returns all nodes with the current node as their parent, in the order specified by
      #   <tt>:order</tt> (<tt>[grandchild1, grandchild2]</tt> when called on <tt>child</tt>)
      # * <tt>parent</tt> - Returns the node referenced by the foreign key (<tt>:parent_id</tt> by
      #   default) (<tt>root</tt> when called on <tt>child</tt>)
      # * <tt>siblings</tt> - Returns all the children of the parent, excluding the current node
      #   (<tt>[grandchild2]</tt> when called on <tt>grandchild1</tt>)
      # * <tt>generation</tt> - Returns all the children of the parent, including the current node (<tt>
      #   [grandchild1, grandchild2]</tt> when called on <tt>grandchild1</tt>)
      # * <tt>ancestors</tt> - Returns all the ancestors of the current node (<tt>[root, child1]</tt>
      #   when called on <tt>grandchild2</tt>)
      # * <tt>root</tt> - Returns the root of the current node (<tt>root</tt> when called on <tt>grandchild2</tt>)
      #
      # Author:: Timothy Bennett (http://lanaer.com)
      # Maintainer:: Garrett Heaver (http://www.linkedin.com/pub/dir/garrett/heaver)

      # Configuration options are:
      #
      # * <tt>child_key</tt> - specifies the column name to use for tracking of the tree (default: +parent_id+)
      def is_tree(options = {})
        configuration = { :class_name => name, :child_key => :parent_id }
        configuration.update(options) if Hash === options

        [:child_key, :order].each { |key| configuration[key] = Array(configuration[key]) if configuration[key] }

        belongs_to :parent, configuration.reject { |k,v| k == :order }
        has n, :children, configuration

        include DataMapper::Is::Tree::InstanceMethods
        extend  DataMapper::Is::Tree::ClassMethods

        class_eval <<-CLASS, __FILE__, __LINE__
          def self.roots
            all :#{configuration[:child_key]} => nil, :order => [#{configuration[:order].inspect}]
          end

          def self.first_root
            first :#{configuration[:child_key]} => nil, :order => [#{configuration[:order].inspect}]
          end
        CLASS

        class << self
          alias_method :root, :first_root # for people used to the ActiveRecord acts_as_tree
        end
      end

      def is_a_tree(options = {})
        warn('#is_a_tree is depreciated. use #is :tree instead.')
        is :tree, options
      end
      alias_method :can_has_tree, :is_tree # just for fun ;)

      module ClassMethods
      end

      module InstanceMethods
        # Returns list of ancestors, starting with the root.
        #
        #   grandchild1.ancestors # => [root, child]
        def ancestors
          node, nodes = self, []
          nodes << node = node.parent while node.parent
          nodes.reverse
        end

        # Returns the root node of the current node’s tree.
        #
        #   grandchild1.root # => root
        def root
          node = self
          node = node.parent while node.parent
          node
        end
        alias_method :first_root, :root

        # Returns all siblings of the current node.
        #
        #   grandchild1.siblings # => [grandchild2]
        def siblings
          generation - [self]
        end

        # Returns all children of the current node’s parent.
        #
        #   grandchild1.generation # => [grandchild1, grandchild2]
        def generation
          parent ? parent.children : self.class.roots
        end
        alias_method :self_and_siblings, :generation # for those used to the ActiveRecord acts_as_tree

      end

      Model.send(:include, self)
    end # Tree
  end # Is
end # DataMapper
