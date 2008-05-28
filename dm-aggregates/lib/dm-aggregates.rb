require 'rubygems'
gem 'dm-core', '=0.9.1'
require 'data_mapper'

require File.join(File.dirname(__FILE__),'dm-aggregates','resource')
require File.join(File.dirname(__FILE__),'dm-aggregates','repository')
require File.join(File.dirname(__FILE__),'dm-aggregates','adapters','data_objects_adapter')
