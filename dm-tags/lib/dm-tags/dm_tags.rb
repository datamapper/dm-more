module DataMapper
  module Resource
    class << self
      # FIXME: remove alias method chain like code
      alias_method :old_included, :included
      def included(receiver)
        old_included(receiver)
        receiver.send(:include, DataMapper::Tags)
      end
    end
  end
end
module DataMapper
  module Tags
    module SingletonMethods
      # Class Methods
      def tagged_with(string, options = {})
        tag = Tag.first(:name => string)
        conditions = {}
        conditions['taggings.tag_id'] = tag.id
        conditions['taggings.tag_context'] = options.delete(:on) if options[:on]
        conditions.merge!(options)
        all(conditions)
      end

      def taggable?
        true
      end
    end

    module ClassMethods
      def has_tags_on(*associations)
        associations.flatten!
        associations.uniq!

        has n, :taggings, Tagging, :child_key => [ :taggable_id ], :taggable_type => self

        before :destroy, :destroy_taggings

        unless instance_methods(false).include?('destroy_taggings')
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def destroy_taggings
              taggings.destroy!
            end
          RUBY
        end

        private :taggings, :taggings=, :destroy_taggings

        extend(DataMapper::Tags::SingletonMethods)

        associations.each do |association|
          association = association.to_s
          singular    = association.singular

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            property :frozen_#{singular}_list, Text

            has n, :#{singular}_taggings, Tagging, :child_key => [ :taggable_id ], :taggable_type => self, :tag_context => '#{association}'
            has n, :#{association},       Tag,     :through => :#{singular}_taggings, :via => :tag, :order => [ :name ]

            before :save, :update_#{association}

            def #{singular}_list
              @#{singular}_list ||= self.#{association}.map { |tag| tag.name }
            end

            def #{singular}_list=(string)
              @#{singular}_list = string.to_s.split(',').map { |name| name.gsub(/[^\\w\\s_-]/i, '').strip }.uniq.sort
            end

            alias #{singular}_collection= #{singular}_list=

            def update_#{association}

              remove_tags = self.frozen_#{singular}_list.to_s.split(',') - self.#{singular}_list
              tags        = self.#{association}

              tags.all(:name => remove_tags).each do |tag|
                tags.delete(tag)
              end

              self.#{singular}_list.each do |name|
                tag = Tag.first_or_new(:name => name)
                tags << tag unless tags.include?(tag)
              end

              self.frozen_#{singular}_list = tags.map { |tag| tag.name }.join(',')
            end

            ##
            # Helper methods to make setting tags easier
            #
            def #{singular}_collection
              self.#{association}.map { |tag| tag.name }.join(', ')
            end

            ##
            # Like tag_collection= except it only add's tags
            #
            def add_#{singular}(string)
              tag_names = string.to_s.split(',').map { |name| name.gsub(/[^\\w\\s_-]/i, '').strip }
              tag_names.concat(self.#{singular}_list)
              @#{singular}_list = tag_names.uniq.sort
            end
          RUBY
        end
      end

      def has_tags(*)
        has_tags_on :tags
      end

      def taggable?
        false
      end
    end

    module InstanceMethods
      def taggable?
        model.taggable?
      end
    end

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
    end
  end
end
