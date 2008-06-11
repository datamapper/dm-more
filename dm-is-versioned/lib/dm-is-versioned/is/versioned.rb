module DataMapper
  module Is
    module Versioned
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Author:: Nolan Darilek
      module ClassMethods
        def is_versioned
          property :version, Integer, :nullable => false, :default => 0

          include DataMapper::Is::Versioned::InstanceMethods

          class_eval <<-END, __FILE__, __LINE__
          class #{self.name}Version
            include DataMapper::Resource
          end
          END

        end

      end

      module InstanceMethods
      end

    end # Tree
  end # Is
end # DataMapper
