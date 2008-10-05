require 'dm-core'
module DataMapper
  module Resource
    class << self
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
    module ClassMethods
      def has_tags_on(*args)
        args.flatten!
        args.uniq!

        self.extend(DataMapper::Tags::SingletonMethods)

        args.map{|arg| arg.to_sym}.each do |arg|
          class_eval <<-RUBY
          property :frozen_#{arg.to_s.singular}_list, String
          has n, :#{arg.to_s.singular}_taggings, :class_name => "Tagging", :child_key => [:taggable_id],
          :taggable_type => self.to_s, :tag_context => "#{arg}"
          before :save, :update_#{arg}

          def #{arg}
            #{arg.to_s.singular}_taggings.map{|tagging| tagging.tag}
          end

          def #{arg.to_s.singular}_list
            @#{arg.to_s.singular}_list || #{arg}.map{|#{arg.to_s.singular}| #{arg.to_s.singular}.name}.sort
          end

          def #{arg.to_s.singular}_list=(string)
            @#{arg.to_s.singular}_list = string.to_s.split(",").map{|name| name.gsub(/[^\\w\\s_-]/i,"").strip}.uniq.sort
          end

          def update_#{arg}
            return if #{arg.to_s.singular}_list.empty?
            deleted_#{arg} = frozen_#{arg.to_s.singular}_list.to_s.split(',') - #{arg.to_s.singular}_list
            deleted_#{arg}.each do |name|
              tag = Tag.first(:name => name)
              tagging = #{arg.to_s.singular}_taggings.first(:tag_id => tag.id)
              tagging.destroy
              #{arg.to_s.singular}_taggings.reload
            end
            #{arg.to_s.singular}_list.each do |name|
              tag = Tag.first(:name => name)
              next if #{arg}.to_a.include?(tag)
              tag = Tag.create!(:name => name) unless tag
              #{arg.to_s.singular}_taggings << Tagging.new(:tag => tag, :taggable_type => self.class.to_s, :tag_context => "#{arg}")
            end
            self.frozen_#{arg.to_s.singular}_list = #{arg}.map{|#{arg.to_s.singular}| #{arg.to_s.singular}.name}.sort.join(',')
          end
        RUBY
      end
    end

  def has_tags(*args)
    has_tags_on :tags
  end

  def taggable?
    false
  end
end

module SingletonMethods
  # Class Methods
  def tagged_with(string, options = {})
    tag = Tag.first(:name => string)
    conditions = {}
    conditions[:tag_id] = tag.id
    conditions[:tag_context] = options[:on] if options[:on]
    Tagging.all(conditions).map{|tagging| tagging.taggable}
  end

  def taggable?
    true
  end
end

module InstanceMethods
  def taggable?
    self.class.taggable?
  end
end

def self.included(receiver)
  receiver.send(:include, InstanceMethods)
  receiver.extend(ClassMethods)
end
end
end
