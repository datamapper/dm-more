class <%= class_name %>
  include DataMapper::Resource

  property :id, Serial
<% Array(attributes).each do |attribute| -%>
  property :<%= attribute.name %>, <%= attribute.type.to_s.capitalize %>, :required => true
<% end -%>
<% unless options[:skip_timestamps] -%>
  property :created_at, DateTime, :required => true
  property :updated_at, DateTime, :required => true
<% end -%>

end
