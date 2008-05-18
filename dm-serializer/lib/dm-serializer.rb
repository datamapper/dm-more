require Pathname('rexml/document')

begin
  require 'faster_csv'
rescue LoadError
  nil
end

begin
  require Pathname('json/ext')
rescue LoadError
  require Pathname('json/pure')
end

module DataMapper
  module Serialize

    # Serialize a Resource to JavaScript Object Notation (JSON; RFC 4627)
    #
    # @return <String> a JSON representation of the Resource
    def to_json
      result = '{ '
      fields = []
      self.class.properties(self.repository.name).each do |property|
        fields << "#{property.name.to_json}: #{self.send(property.getter).to_json}"
      end
      if self.class.respond_to?(:read_only_attributes)
        self.class.read_only_attributes.each do |property|
          fields << "#{property.to_json}: #{self.send(property).to_json}"
        end
      end
      result << fields.join(', ')
      result << ' }'
      result
    end

    # Serialize a Resource to comma-separated values (CSV).
    #
    # @return <String> a CSV representation of the Resource
    def to_csv(writer = '')
      FasterCSV.generate(writer) do |csv|
        row = []
        self.class.properties(self.repository.name).each do |property|
         row << self.send(property.name).to_s
        end
        csv << row
      end
    end

    # Serialize a Resource to XML
    #
    # @return <REXML::Document> an XML representation of this Resource
    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end

    # Serialize a Resource to YAML
    #
    # @return <YAML> a YAML representation of this Resource
    def to_yaml(opts = {})
      YAML::quick_emit(object_id,opts) do |out|
        out.map(nil,to_yaml_style) do |map|
          self.class.properties(self.repository.name).each do |property|
            value = self.send(property.name.to_sym)
            map.add(property.name, value.is_a?(Class) ? value.to_s : value)
          end
          (self.instance_variable_get("@yaml_addes") || []).each do |k,v|
            map.add(k.to_s,v)
          end
        end
      end
    end

    protected

    # Return the name of this Resource - to be used as the root element name.
    # This can be overloaded.
    #
    # @return <String> name of this Resource
    def xml_element_name
      DataMapper::Inflection.underscore(self.class.name)
    end

    # Return a REXML::Document representing this Resource
    #
    # @return <REXML::Document> an XML representation of this Resource
    def to_xml_document(opts={})
      doc = REXML::Document.new
      root = doc.add_element(xml_element_name)
      keys = self.class.key(self.repository.name)
      keys.each do |key|
        value = self.send(key.name)
        root.attributes[key.name.to_s] = value.to_s
      end

      #TODO old code base was converting single quote to double quote on attribs

      self.class.properties(self.repository.name).each do |property|
        if !keys.include?(property)
          value = self.send(property.name)
          node = root.add_element(property.name.to_s)
          node << REXML::Text.new(value.to_s) unless value.nil?
        end
      end
      doc
    end

  end # module Serialize

  module Resource
    include Serialize
  end # module Resource
end # module DataMapper
