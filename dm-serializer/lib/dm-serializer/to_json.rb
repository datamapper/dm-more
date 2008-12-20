require 'dm-serializer/common'

begin
  gem('json')
  require 'json/ext'
rescue LoadError
  gem('json_pure')
  require 'json/pure'
end

module DataMapper
  module Serialize
    # Serialize a Resource to JavaScript Object Notation (JSON; RFC 4627)
    #
    # @return <String> a JSON representation of the Resource
    def to_json(*args)
      options = args.first || {}
      result = '{ '
      fields = []

      propset = properties_to_serialize(options)

      fields += propset.map do |property|
        "#{property.name.to_json}: #{send(property.getter).to_json}"
      end

      if self.respond_to?(:serialize_properties)
        self.serialize_properties.each do |k,v|
          fields << "#{k.to_json}: #{v.to_json}"
        end
      end

      if self.class.respond_to?(:read_only_attributes) && exclude_read_only
        self.class.read_only_attributes.each do |property|
          fields << "#{property.to_json}: #{send(property).to_json}"
        end
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

  # the json gem adds Object#to_json, which breaks the DM proxies, since it
  # happens *after* the proxy has been blank slated. This code removes the added
  # method, so it is delegated correctly to the Collection
  [
    Associations::OneToMany::Proxy,
    (Associations::ManyToOne::Proxy if defined?(Associations::ManyToOne::Proxy)),
    Associations::ManyToMany::Proxy
  ].each do |proxy|
    [:to_json].each do |method|
      proxy.send(:undef_method, :to_json) rescue nil
    end
  end

  class Collection
    def to_json(*args)
      opts = args.first || {}
      "[" << map {|e| e.to_json(opts)}.join(",") << "]"
    end
  end
end
