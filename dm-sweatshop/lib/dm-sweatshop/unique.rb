module DataMapper
  class Sweatshop
    class Unique
      require 'parse_tree'

      cattr_accessor :count_map

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

      cattr_accessor :parser

      def self.key_for(&block)
        klass = Class.new
        name = "tmp"
        klass.send(:define_method, name, &block)
        self.parser ||= ParseTree.new(false)
        self.parser.parse_tree_for_method(klass, name).last
      end
    end
  end
end
