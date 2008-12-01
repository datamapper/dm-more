require 'rubygems'

gem 'dm-core', '~>0.9.7'
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
        conditions[:tag_id] = tag.id
        conditions[:tag_context] = options[:on] if options[:on]
        Tagging.all(conditions).map { |tagging| tagging.taggable }
      end

      def taggable?
        true
      end
    end

    module ClassMethods
      def has_tags_on(*associations)
        associations.flatten!
        associations.uniq!

        self.extend(DataMapper::Tags::SingletonMethods)

        associations.each do |association|
          association = association.to_s
          singular    = association.singular

          class_eval <<-RUBY
            property :frozen_#{singular}_list, String

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
