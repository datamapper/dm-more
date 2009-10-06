require 'dm-serializer/common'

require 'json'

module DataMapper
  module Serialize
    # Serialize a Resource to JavaScript Object Notation (JSON; RFC 4627)
    #
    # @return <String> a JSON representation of the Resource
    def to_json(*args)
      options = args.first || {}

      result = {}

      propset = properties_to_serialize(options)

      propset.each do |property|
        result[property.name] = __send__(property.name)
      end

      # add methods
      (options[:methods] || []).each do |meth|
        if self.respond_to?(meth)
          result[meth] = __send__(meth)
        end
      end

      # Note: if you want to include a whole other model via relation, use :methods
      # comments.to_json(:relationships=>{:user=>{:include=>[:first_name],:methods=>[:age]}})
      # add relationships
      # TODO: This needs tests and also needs to be ported to #to_xml and #to_yaml
      (options[:relationships] || {}).each do |rel,opts|
        if self.respond_to?(rel)
          result[rel] = send(rel).to_json(opts.merge(:to_json => false))
        end
      end

      # default to making JSON
      if options.fetch(:to_json, true)
        result.to_json
      else
        result
      end
    end
  end


  module Associations
    # the json gem adds Object#to_json, which breaks the DM proxies, since it
    # happens *after* the proxy has been blank slated. This code removes the added
    # method, so it is delegated correctly to the Collection
    proxies = []

    proxies << ManyToMany::Proxy if defined?(ManyToMany::Proxy)
    proxies << OneToMany::Proxy  if defined?(OneToMany::Proxy)
    proxies << ManyToOne::Proxy  if defined?(ManyToOne::Proxy)

    proxies.each do |proxy|
      if proxy.public_instance_methods.any? { |m| m.to_sym == :to_json }
        proxy.send(:undef_method, :to_json)
      end
    end
  end

  class Collection
    def to_json(*args)
      opts = args.first || {}

      options = opts.merge(:to_json => false)
      collection = map { |e| e.to_json(options) }

      # default to making JSON
      if opts.fetch(:to_json, true)
        collection.to_json
      else
        collection
      end
    end
  end

  if Serialize::Support.dm_validations_loaded?

    module Validate
      class ValidationErrors
        def to_json(*args)
          errors.to_hash.to_json
        end
      end
    end

  end
end
