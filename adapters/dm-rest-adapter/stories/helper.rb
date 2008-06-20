$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../lib/rest_adapter")
require 'rubygems'
require 'spec'
require 'tempfile'
require 'dm-core'
#require 'pathname'
#require Pathname(__FILE__).dirname.parent.expand_path + '../../lib/rest_adapter'
require File.join(File.dirname(__FILE__), *%w[resources helpers story_helper])
require File.join(File.dirname(__FILE__), *%w[resources steps using_rest_adapter])
