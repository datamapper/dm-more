module DataMapper
  class Sweatshop
    begin
      require 'parse_tree'
    rescue LoadError
      puts "DataMapper::Sweatshop::Unique - ParseTree could not be loaded, anonymous uniques will not be allowed"
    end

    class Unique
      def self.unique(key = nil, &block)
        self.count_map ||= Hash.new() { 0 }

        key ||= key_for(&block)
        result = block[self.count_map[key]] 
        self.count_map[key] += 1

        result
      end

      def self.reset!
        self.count_map = Hash.new() { 0 }
      end

      private

      cattr_accessor :count_map
      cattr_accessor :parser

      def self.key_for(&block)
        raise "You need to install ParseTree to use anonymous an anonymous unique (gem install ParseTree). In the mean time, explicitly declare a key: unique(:my_key) { ... }" unless Object::const_defined?("ParseTree")

        klass = Class.new
        name = "tmp"
        klass.send(:define_method, name, &block)
        self.parser ||= ParseTree.new(false)
        self.parser.parse_tree_for_method(klass, name).last
      end
    end
  end
end
