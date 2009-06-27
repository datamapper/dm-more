migration 1, :<%= class_name.underscore %> do
  up do
    create_table :<%= table_name %> do
<% Array(attributes).each do |attribute| -%>
      column :<%= attribute.name if attribute %>, <%= attribute.type.to_s.capitalize %>, :nullable? => false
<% end -%>
<% unless options[:skip_timestamps] -%>
      column :created_at, DateTime, :nullable? => false
      column :updated_at, DateTime, :nullable? => false
<% end -%>
    end
  end

  down do
    drop_table :<%= table_name %>
  end
end
