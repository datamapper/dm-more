require 'rubygems'
require 'data_mapper'

require File.join(File.dirname(__FILE__),'dm-timestamps','magic_columns')

module DataMapper
  module Timestamps
      
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          include DataMapper::Timestamp::MagicColumns
        end
      end
          
      module ClassMethods 
      end #module ClassMethods    
  end
end
