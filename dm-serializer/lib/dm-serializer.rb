begin
  require 'active_support/ordered_hash'
rescue LoadError
  require 'extlib/dictionary'
  module ActiveSupport
    OrderedHash = Dictionary
  end
end

require 'dm-serializer/to_json'
require 'dm-serializer/to_xml'
require 'dm-serializer/to_yaml'
require 'dm-serializer/to_csv'
