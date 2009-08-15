module DataMapper
  module Is
    ##
    # = Is Versioned
    # The Versioned module will configure a model to be versioned.
    #
    # The is-versioned plugin functions differently from other versioning
    # solutions (such as acts_as_versioned), but can be configured to
    # function like it if you so desire.
    #
    # The biggest difference is that there is not an incrementing 'version'
    # field, but rather, any field of your choosing which will be unique
    # on update.
    #
    # == Setup
    # For simplicity, I will assume that you have loaded dm-timestamps to
    # automatically update your :updated_at field. See versioned_spec for
    # and example of updating the versioned field yourself.
    #
    #   class Story
    #     include DataMapper::Resource
    #     property :id, Serial
    #     property :title, String
    #     property :updated_at, DateTime
    #
    #     is_versioned :on => [:updated_at]
    #   end
    #
    # == Auto Upgrading and Auto Migrating
    #
    #   Story.auto_migrate! # => will run auto_migrate! on Story::Version, too
    #   Story.auto_upgrade! # => will run auto_upgrade! on Story::Version, too
    #
    # == Usage
    #
    #   story = Story.get(1)
    #   story.title = "New Title"
    #   story.save # => Saves this story and creates a new version with the
    #              #    original values.
    #   story.versions.size # => 1
    #
    #   story.title = "A Different New Title"
    #   story.save
    #   story.versions.size # => 2
    #
    # TODO: enable replacing a current version with an old version.
    module Versioned
      def is_versioned(options = {})
        @on = on = options[:on]

        after_class_method :auto_migrate! do |retval|
          self::Version.auto_migrate!
        end

        after_class_method :auto_upgrade! do |retval|
          self::Version.auto_upgrade!
        end

        properties.each do |property|
          name = property.name
          before "#{name}=".to_sym do
            unless (value = property.get(self)).nil? || pending_version_attributes.key?(name)
              pending_version_attributes[name] = value
            end
          end
        end

        after :update do |retval|
          if retval && pending_version_attributes.key?(on)
            model::Version.create(attributes.merge(pending_version_attributes))
            pending_version_attributes.clear
          end

          retval
        end

        extend ClassMethods
        include InstanceMethods
      end

      module ClassMethods
        def const_missing(name)
          if name == :Version
            model = DataMapper::Model.new

            properties.each do |property|
              type = property.type
              type = Class if type == DataMapper::Types::Discriminator

              options = property.options.merge(
                :key    => property.name == @on,
                :serial => false
              )

              model.property(property.name, type, options)
            end

            const_set(name, model)
          else
            super
          end
        end
      end # ClassMethods

      module InstanceMethods
        ##
        # Returns a hash of original values to be stored in the
        # versions table when a new version is created. It is
        # cleared after a version model is created.
        #
        # --
        # @return <Hash>
        def pending_version_attributes
          @pending_version_attributes ||= {}
        end

        ##
        # Returns a collection of other versions of this resource.
        # The versions are related on the models keys, and ordered
        # by the version field.
        #
        # --
        # @return <Collection>
        def versions
          version_model = model.const_get(:Version)
          query = model.key.zip(key).map { |p, v| [ p.name, v ] }.to_hash
          query.merge(:order => version_model.key.map { |k| k.name.desc })
          version_model.all(query)
        end
      end # InstanceMethods
    end # Versioned
  end # Is
end # DataMapper
