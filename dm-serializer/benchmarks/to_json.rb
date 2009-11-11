require "rubygems"
require 'pathname'
require 'better-benchmark'

gem 'dm-core', '0.10.2'
require 'dm-core'

spec_dir_path = Pathname(__FILE__).dirname.expand_path
$LOAD_PATH.unshift(spec_dir_path.parent + 'lib/')
require 'dm-serializer'

def load_driver(name, default_uri)
  begin
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    DataMapper::Repository.adapters[:alternate] = DataMapper::Repository.adapters[name]
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')

module DataMapper
  module Serialize
    # Serialize a Resource to JavaScript Object Notation (JSON; RFC 4627)
    #
    # @return <String> a JSON representation of the Resource
    def to_json_old(*args)
      options = args.first || {}
      result = '{ '
      fields = []

      propset = properties_to_serialize(options)

      fields += propset.map do |property|
        "#{property.name.to_json}: #{send(property.name).to_json}"
      end

      # add methods
      (options[:methods] || []).each do |meth|
        if self.respond_to?(meth)
          fields << "#{meth.to_json}: #{send(meth).to_json}"
        end
      end

      # Note: if you want to include a whole other model via relation, use :methods
      # comments.to_json(:relationships=>{:user=>{:include=>[:first_name],:methods=>[:age]}})
      # add relationships
      # TODO: This needs tests and also needs to be ported to #to_xml and #to_yaml
      (options[:relationships] || {}).each do |rel,opts|
        if self.respond_to?(rel)
          fields << "#{rel.to_json}: #{send(rel).to_json(opts)}"
        end
      end

      result << fields.join(', ')
      result << ' }'
      result
    end
  end

  class Collection
    def to_json_old(*args)
      opts = args.first || {}
      '[' << map { |e| e.to_json_old(opts) }.join(',') << ']'
    end
  end
end




class Cow
  include DataMapper::Resource

  property :id,        Integer, :key => true
  property :composite, Integer, :key => true
  property :name,      String
  property :breed,     String

  has n, :baby_cows, :model => 'Cow'
  belongs_to :mother_cow, :model => 'Cow', :required => false
end

DataMapper.auto_migrate!
cow = Cow.create(
  :id        => 89,
  :composite => 34,
  :name      => 'Berta',
  :breed     => 'Guernsey'
)

10.times do |n|
  Cow.create(
    :id         => n*10,
    :composite  => n,
    :name       => "Bertha"*n,
    :breed      => "Mooing#{n}"
  )
end

all_cows = Cow.all.reload

puts "Benchmarking single resource serialization."
puts "Set 1: old method"
puts "Set 2: new method"
result = Benchmark.compare_realtime(
    :iterations => 10,
    :inner_iterations => 20000,
    :verbose => true
) { |iteration|
  cow.to_json_old
}.with { |iteration|
  cow.to_json
}

Benchmark.report_on result

puts

puts "Benchmarking collection serialization."
puts "Set 1: old method"
puts "Set 2: new method"
result = Benchmark.compare_realtime(
    :iterations => 10,
    :inner_iterations => 5000,
    :verbose => true
) { |iteration|
  all_cows.to_json_old
}.with { |iteration|
  all_cows.to_json
}

Benchmark.report_on result
