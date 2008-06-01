module DataMapper
  # Voyeur's allow you to add callback hooks to DataMapper::Resource objects in a separate class. This is great
  # for separating out logic that is not really part of the model, but needs to be triggered by a model, or models.
  module Voyeur
    
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    module ClassMethods

      attr_accessor :neighborhood_watch

      def initialize
        self.neighborhood_watch = []
      end

      # Assign an Array of Class names to watch.
      #   peep User, Article, Topic
      def peep(*args)
        # puts "#{self.to_s} peeping... #{args.collect{|c| DataMapper::Inflection.classify(c.to_s)}.join(', ')}"
        self.neighborhood_watch = args
      end
      
      def before(sym, &block)
        self.neighborhood_watch.each do |klass|
          klass.before(sym.to_sym, &block)
        end
      end
      
      def after(sym, &block)
        self.neighborhood_watch.each do |klass|
          klass.after(sym.to_sym, &block)
        end
      end
      
      def before_class_method(sym, &block)
        self.neighborhood_watch.each do |klass|
          klass.before_class_method(sym.to_sym, &block)
        end
      end
      
      def after_class_method(sym, &block)
        self.neighborhood_watch.each do |klass|
          klass.after_class_method(sym.to_sym, &block)
        end
      end
      
    end # ClassMethods
    
  end # Voyeur
end # DataMapper

if $0 == __FILE__ 
  require 'rubygems'
  gem 'dm-core'
  require 'data_mapper'
  
  FileUtils.touch(File.join(Dir.pwd, "migration_test.db"))
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/migration_test.db")
  
  class Foo
    include DataMapper::Resource
  
    property :id, Integer, :serial => true
    property :bar, Text
  end
  
  Foo.auto_migrate!

  class FooVoyeur
    include DataMapper::Voyeur
  
    peep :foo
    
    before :save do
      raise "Hell!" if self.bar.nil?
      puts "hi"
    end
    
    after :save do
      puts "bye"
    end
  
  end
  
  Foo.new(:bar => "hello").save

end