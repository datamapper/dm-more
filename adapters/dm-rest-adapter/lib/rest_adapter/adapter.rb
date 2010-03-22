module DataMapperRest
  # TODO: Abstract XML support out from the protocol
  # TODO: Build JSON support

  # All http_"verb" (http_post) method calls use method missing in connection class which uses run_verb
  class Adapter < DataMapper::Adapters::AbstractAdapter
    def create(resources)
      resources.each do |resource|
        model = resource.model

        response = connection.http_post("#{resource_name(model)}", resource.to_xml)

        update_with_response(resource, response)
      end
    end

    def read(query)
      model = query.model

      records = if id = extract_id_from_query(query)
        response = connection.http_get("#{resource_name(model)}/#{id}")
        [ parse_resource(response.body, model) ]
      else
        query_string = if (params = extract_params_from_query(query)).any?
          params.map { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
        end

        response = connection.http_get("#{resource_name(model)}#{'?' << query_string if query_string}")
        parse_resources(response.body, model)
      end

      query.filter_records(records)
    end

    def update(dirty_attributes, collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).join

        dirty_attributes.each { |p, v| p.set!(resource, v) }

        response = connection.http_put("#{resource_name(model)}/#{id}", resource.to_xml)

        update_with_response(resource, response)
      end.size
    end

    def delete(collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).join

        response = connection.http_delete("#{resource_name(model)}/#{id}")
        response.kind_of?(Net::HTTPSuccess)
      end.size
    end

    private

    def initialize(*)
      super
      @format = @options.fetch(:format, 'xml')
    end

    def connection
      @connection ||= Connection.new(normalized_uri, @format)
    end

    def normalized_uri
      @normalized_uri ||=
        begin
          query = @options.except(:adapter, :user, :password, :host, :port, :path, :fragment)
          query = nil if query.empty?

          Addressable::URI.new(
            :scheme       => 'http',
            :user         => @options[:user],
            :password     => @options[:password],
            :host         => @options[:host],
            :port         => @options[:port],
            :path         => @options[:path],
            :query_values => query,
            :fragment     => @options[:fragment]
          ).freeze
        end
    end

    def extract_id_from_query(query)
      return nil unless query.limit == 1

      conditions = query.conditions

      return nil unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      return nil unless (key_condition = conditions.select { |o| o.subject.key? }).size == 1

      key_condition.first.value
    end

    def extract_params_from_query(query)
      conditions = query.conditions

      return {} unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      return {} if conditions.any? { |o| o.subject.key? }

      query.options
    end

    def record_from_rexml(entity_element, field_to_property)
      record = {}

      entity_element.elements.map do |element|
        # TODO: push this to the per-property mix-in for this adapter
        field = element.name.to_s.tr('-', '_')
        next unless property = field_to_property[field]
        record[field] = property.typecast(element.text)
      end

      record
    end

    def parse_resource(xml, model)
      doc = REXML::Document::new(xml)

      element_name = element_name(model)

      unless entity_element = REXML::XPath.first(doc, "/#{element_name}")
        raise "No root element matching #{element_name} in xml"
      end

      field_to_property = model.properties(name).map { |p| [ p.field, p ] }.to_hash
      record_from_rexml(entity_element, field_to_property)
    end

    def parse_resources(xml, model)
      doc = REXML::Document::new(xml)

      field_to_property = model.properties(name).map { |p| [ p.field, p ] }.to_hash
      element_name      = element_name(model)

      doc.elements.collect("/#{resource_name(model)}/#{element_name}") do |entity_element|
        record_from_rexml(entity_element, field_to_property)
      end
    end

    def element_name(model)
      model.storage_name(self.name).singularize
    end

    def resource_name(model)
      model.storage_name(self.name)
    end

    def update_with_response(resource, response)
      return unless response.kind_of?(Net::HTTPSuccess) && !response.body.blank?

      model      = resource.model
      properties = model.properties(name)

      parse_resource(response.body, model).each do |key, value|
        if property = properties[key.to_sym]
          property.set!(resource, value)
        end
      end
    end
  end
end
