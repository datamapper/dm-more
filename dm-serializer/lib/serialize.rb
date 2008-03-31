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
        
    # Serialise a resource to YAML
    #      
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
    
    # Serialise a resource to XML
    #
    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end
    
    # Return the name of this resource - to be used as the root element
    # name. This can be overloaded
    #
    def xml_element_name 
      DataMapper::Inflection.underscore(self.class.name)
    end
    
    # Return a REXML::Document representing this resource
    #
    def to_xml_document(opts={}) 
      doc = REXML::Document.new
      root = doc.add_element(xml_element_name)
      keys = self.class.key(self.repository.name)
      keys.each do |key|
        value = self.send(key.name)
        root.attributes[key.name.to_s] = value
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
    
    def to_json
      result = '{ '
      fields = []
      self.class.properties(self.repository.name).each do |property|
        fields << "#{property.name.to_json}: #{self.send(property.name).to_json}"
      end
      result << fields.join(', ')      
      result << ' }'
      result
    end
    
    def to_csv(writer = '')
      FasterCSV.generate(writer) do |csv|
        row = []
        self.class.properties(self.repository.name).each do |property|
         row << self.send(property.name).to_s            
        end
        csv << row
#        csv << self.class.properties(self.repository.name).each {|property| self.send(property.name).to_s}            
      end
    end
    
    #def to_csv(writer = "")
    #  FasterCSV.generate(writer) do |csv|
    #    csv << database_context.table(self.class).columns.map { |column| get_value_for_column(column) }
    #  end
    #  return writer
    #end


  end
end # module DataMapper
