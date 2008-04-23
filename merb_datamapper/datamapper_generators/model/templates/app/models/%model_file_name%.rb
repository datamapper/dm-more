class <%= model_class_name %>
  include DataMapper::Resource
<% model_attributes.each do |attr| -%>
  <%= "property :#{attr.first}, #{attr.last}" %>
<% end -%>
end
