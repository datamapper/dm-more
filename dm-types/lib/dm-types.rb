require 'rubygems'
gem 'dm-core', '=0.9.0'
require 'data_mapper'

require File.join(File.dirname(__FILE__),'dm-types','csv')
require File.join(File.dirname(__FILE__),'dm-types','enum')
require File.join(File.dirname(__FILE__),'dm-types','epoch_time')
require File.join(File.dirname(__FILE__),'dm-types','flag')
require File.join(File.dirname(__FILE__),'dm-types','yaml')