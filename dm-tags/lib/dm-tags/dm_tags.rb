require 'rubygems'

gem 'dm-core', '0.9.12'
require 'dm-core'

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

        class_eval do
          has n, :taggings, :class_name => "Tagging", :child_key => [:taggable_id],
          :taggable_type => self.to_s

          before :destroy, :destroy_taggings unless respond_to?(:destroy_taggings)

          def destroy_taggings
            taggings.destroy!
          end unless respond_to?(:destroy_taggings)

          private :taggings, :taggings=, :destroy_taggings
        end

        self.extend(DataMapper::Tags::SingletonMethods)

        associations.each do |association|
          association = association.to_s
          singular    = association.singular

          class_eval <<-RUBY
            property :frozen_#{singular}_list, Text

            has n, :#{singular}_taggings, :class_name => "Tagging", :child_key => [:taggable_id], :taggable_type => self.to_s, :tag_context => "#{association}"

            before :create, :update_#{association}
            before :update, :update_#{association}

            def #{association}
              #{singular}_taggings.map { |tagging| tagging.tag }.sort_by { |tag| tag.name }
            end

            def #{singular}_list
              @#{singular}_list ||= #{association}.map { |tag| tag.name }
            end

            def #{singular}_list=(string)
              @#{singular}_list = string.to_s.split(',').map { |name| name.gsub(/[^\\w\\s_-]/i, '').strip }.uniq.sort
            end

            def update_#{association}
              return if #{singular}_list.empty?

              Tag.all(:name => frozen_#{singular}_list.to_s.split(',') - #{singular}_list).each do |tag|
                if tagging = #{singular}_taggings.first(:tag_id => tag.id)
                  tagging.destroy
                end
              end

              #{singular}_taggings.reload

              #{singular}_list.each do |name|
                tag = Tag.first(:name => name)
                next if tag && #{association}.include?(tag)
                tag ||= Tag.create(:name => name)
                #{singular}_taggings << Tagging.new(:tag => tag, :taggable_type => self.class.to_s, :tag_context => "#{association}")
              end

              self.frozen_#{singular}_list = #{association}.map { |tag| tag.name }.join(',')
            end

            ##
            # Helper methods to make setting tags easier
            # FIXME: figure out why calling #{singular}_list=(string) won't work
            def #{singular}_collection=(string)
              @#{singular}_list = string.to_s.split(',').map { |name| name.gsub(/[^\\w\\s_-]/i, '').strip }.uniq.sort
            end

            ##
            # Helper methods to make setting tags easier
            #
            def #{singular}_collection
              #{association}.map { |tag| tag.name }.join(', ')
            end

            ##
            # Like tag_collection= except it only add's tags
            #
            def add_#{singular}(string)
              tag_array = string.to_s.split(',').map { |name| name.gsub(/[^\\w\\s_-]/i, '').strip }.uniq.sort
              @#{singular}_list = (tag_array + #{singular}_list)
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
        self.class.taggable?
      end
    end

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
    end
  end
end
