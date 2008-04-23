$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

module Merb
  module Plugins
    def self.config
      @config ||= {}
    end
  end
end