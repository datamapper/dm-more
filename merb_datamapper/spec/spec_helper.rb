$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'

gem 'dm-core', '=0.9.5'
require 'dm-core'

module Merb
  module Plugins
    def self.config
      @config ||= {}
    end
  end
end
