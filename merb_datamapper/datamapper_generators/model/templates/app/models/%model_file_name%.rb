class <%= model_class_name %>
  include DataMapper::Resource
  
  <% model_attributes.each do |name,type| -%>
  property :<%=name-%>, <%=type%>
  <% end %>
end
