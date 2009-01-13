# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '~>0.9.10'
require 'dm-core'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'data_objects_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'postgres_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'mysql_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'delete_constraint'

module DataMapper
  module Associations
    class Relationship
      attr_reader :delete_constraint
      OPTIONS << :constraint

      def initialize(name, repository_name, child_model, parent_model, options = {})
        assert_kind_of 'name',            name,            Symbol
        assert_kind_of 'repository_name', repository_name, Symbol
        assert_kind_of 'child_model',     child_model,     String, Class
        assert_kind_of 'parent_model',    parent_model,    String, Class

        if child_properties = options[:child_key]
          assert_kind_of 'options[:child_key]', child_properties, Array
        end

        if parent_properties = options[:parent_key]
          assert_kind_of 'options[:parent_key]', parent_properties, Array
        end

        @name              = name
        @repository_name   = repository_name
        @child_model       = child_model
        @child_properties  = child_properties   # may be nil
        @query             = options.reject { |k,v| OPTIONS.include?(k) }
        @parent_model      = parent_model
        @parent_properties = parent_properties  # may be nil
        @options           = options
        @delete_constraint = options[:constraint]

        # attempt to load the child_key if the parent and child model constants are defined
        if model_defined?(@child_model) && model_defined?(@parent_model)
          child_key
        end
      end

    end
  end
end

module DataMapper
  module Associations
    DELETE_CONSTRAINT_OPTIONS = [:protect, :destroy, :destroy!, :set_nil, :skip]
    def has(cardinality, name, options = {})

      # NOTE: the reason for this fix is that with the ability to pass in two
      # hashes into has() there might be instances where people attempt to
      # pass in the options into the name part and not know why things aren't
      # working for them.
      if name.kind_of?(Hash)
        name_through, through = name.keys.first, name.values.first
        cardinality_string = cardinality.to_s == 'Infinity' ? 'n' : cardinality.inspect
        warn("In #{self.name} 'has #{cardinality_string}, #{name_through.inspect} => #{through.inspect}' is deprecated. Use 'has #{cardinality_string}, #{name_through.inspect}, :through => #{through.inspect}' instead")
      end

      options = options.merge(extract_min_max(cardinality))
      options = options.merge(extract_throughness(name))

      # do not remove this. There is alot of confusion on people's
      # part about what the first argument to has() is.  For the record it
      # is the min cardinality and max cardinality of the association.
      # simply put, it constraints the number of resources that will be
      # returned by the association.  It is not, as has been assumed,
      # the number of results on the left and right hand side of the
      # reltionship.
      if options[:min] == n && options[:max] == n
        raise ArgumentError, 'Cardinality may not be n..n.  The cardinality specifies the min/max number of results from the association', caller
      end

      klass = options[:max] == 1 ? OneToOne : OneToMany
      klass = ManyToMany if options[:through] == DataMapper::Resource
      relationship = klass.setup(options.delete(:name), self, options)

      delete_constraint_options = DELETE_CONSTRAINT_OPTIONS.map { |o| ":#{o}" }
      raise ArgumentError, ":constraint option must be one of #{delete_constraint_options * ', '}" if options[:constraint] && !DELETE_CONSTRAINT_OPTIONS.include?(options[:constraint])

      # Please leave this in - I will release contextual serialization soon
      # which requires this -- guyvdb
      # TODO convert this to a hook in the plugin once hooks work on class
      # methods
      self.init_has_relationship_for_serialization(relationship) if self.respond_to?(:init_has_relationship_for_serialization)

      relationship
    end
  end
end

module DataMapper
  module Constraints

    include DeleteConstraint
    def self.included(model)
      model.class_eval <<-EOS, __FILE__, __LINE__
        if method_defined?(:destroy)
          before :destroy, :check_delete_constraints
        end
      EOS
    end
  end

  class AutoMigrator
    include Extlib::Hook
    include DataMapper::Constraints::DataObjectsAdapter::Migration
  end

  module Adapters
    if defined?(MysqlAdapter)
      MysqlAdapter.send :include, DataMapper::Constraints::MysqlAdapter::SQL
    end

    if defined?(PostgresAdapter)
      PostgresAdapter.send :include, DataMapper::Constraints::PostgresAdapter::SQL
    end
  end
end
