module DataMapper
  module Voyeur
    
    def self.included(klass)
      puts "i've been included into #{klass}"
      klass.extend(ClassMethods)
    end
    
    module ClassMethods

      attr_accessor :peep_list

      def initialize
        self.peep_list = []
      end

      def peep(*args)
        puts "#{self.to_s} peeping... #{args.collect{|c| DataMapper::Inflection.classify(c.to_s)}.join(', ')}"
        self.peep_list = args.collect{|c| DataMapper::Inflection.constantize(DataMapper::Inflection.classify(c.to_s))}
      end
      
      def before(sym, &block)
        self.peep_list.each do |klass|
          klass.before(sym.to_sym, &block)
        end
      end
      
      def after(sym, &block)
        self.peep_list.each do |klass|
          klass.after(sym.to_sym, &block)
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