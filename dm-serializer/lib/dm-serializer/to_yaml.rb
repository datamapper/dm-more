require 'dm-serializer/common'

module DataMapper
  module Serialize
    # Serialize a Resource to YAML
    #
    # @return <YAML> a YAML representation of this Resource
    def to_yaml(opts_or_emitter = {})
      if !opts_or_emitter.is_a?(Hash)
        emitter = opts_or_emitter
        opts = {}
      else
        emitter = {}
        opts = opts_or_emitter
      end

      YAML::quick_emit(object_id,emitter) do |out|
        out.map(nil,to_yaml_style) do |map|
          properties_to_serialize(opts).each do |property|
            value = __send__(property.name.to_sym)
            map.add(property.name, value.is_a?(Class) ? value.to_s : value)
          end
          # add methods
          (opts[:methods] || []).each do |meth|
            if respond_to?(meth)
              map.add(meth.to_sym, __send__(meth))
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
    def to_yaml(opts_or_emitter = {})
      if !opts_or_emitter.is_a?(Hash)
        to_a.to_yaml(opts_or_emitter)
      else
        # FIXME: Don't double handle the YAML (remove the YAML.load)
        to_a.collect {|x| YAML.load(x.to_yaml(opts_or_emitter)) }.to_yaml
      end
    end
  end

  if Serialize::Support.dm_validations_loaded?

    module Validate
      class ValidationErrors
        def to_yaml(*args)
          errors.to_hash.to_yaml(*args)
        end
      end
    end

  end
end
