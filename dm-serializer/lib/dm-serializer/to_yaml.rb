require 'dm-serializer/common'

module DataMapper
  module Serialize
    # Serialize a Resource to YAML
    #
    # @return <YAML> a YAML representation of this Resource
    def to_yaml(opts = {})
      YAML::quick_emit(object_id,opts) do |out|
        out.map(nil,to_yaml_style) do |map|
          propset = properties_to_serialize(opts)
          propset.each do |property|
            value = send(property.name.to_sym)
            map.add(property.name, value.is_a?(Class) ? value.to_s : value)
          end
          # add methods
          (opts[:methods] || []).each do |meth|
            if self.respond_to?(meth)
              map.add(meth.to_sym, send(meth))
            end
          end
          (instance_variable_get("@yaml_addes") || []).each do |k,v|
            map.add(k.to_s,v)
          end
        end
      end
    end
  end

  class Collection
    def to_yaml(opts = {})
      # FIXME: Don't double handle the YAML (remove the YAML.load)
      to_a.collect {|x| YAML.load(x.to_yaml(opts)) }.to_yaml
    end
  end
end
