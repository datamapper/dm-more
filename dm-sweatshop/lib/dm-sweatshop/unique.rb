module DataMapper
  class Sweatshop
    class Unique
      require 'ruby2ruby'

      cattr_accessor :count_map

      def self.unique(key = nil, &block)
        self.count_map ||= Hash.new() { 0 }

        key ||= block.to_ruby
        result = block[self.count_map[key]] 
        self.count_map[key] += 1

        result
      end

      def self.reset!
        self.count_map = Hash.new() { 0 }
      end
    end
  end
end
