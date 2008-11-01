require 'rubygems'
require 'pathname'

gem 'dm-core', '~>0.9.7'
require 'dm-core'

spec_dir_path = Pathname(__FILE__).dirname.expand_path
require spec_dir_path.parent + 'lib/dm-serializer'

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s

  lib = "do_#{name}"

  begin
    gem lib, '~>0.9.7'
    require lib
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    DataMapper::Repository.adapters[:alternate] = DataMapper::Repository.adapters[name]
    true
  rescue Gem::LoadError => e
    warn "Could not load #{lib}: #{e}"
    false
  end
end

module Harness
  class ToXml
    def method_name
      :to_xml
    end

    def extract_value(result, key)
      doc = REXML::Document.new(result)
      element = doc.elements[1].elements[key]
      value = element ? element.text : nil
      boolean_conversions = {"true" => true, "false" => false}
      value = boolean_conversions[value] if boolean_conversions.has_key?(value)
      value
    end
  end

  class ToJson
    def method_name
      :to_json
    end

    def extract_value(result, key)
      JSON.parse(result)[key]
    end
  end
end

ENV['ADAPTER'] ||= 'sqlite3'

HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')


# require fixture resources
Dir[spec_dir_path + "fixtures/*.rb"].each do |fixture_file|
  require fixture_file
end
