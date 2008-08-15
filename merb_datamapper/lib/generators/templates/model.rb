<% with_modules(modules) do -%>
class <%= class_name %>
  include DataMapper::Resource
<% attributes.each do |name, type| %>
  property :<%= name -%>, <%= datamapper_type(type) -%>
<% end %>

end
<% end -%>
