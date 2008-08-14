Merb::Generators::ModelGenerator.option :migration, :as => :boolean, :desc => 'Also generate a dm-migration for the model'

Merb::Generators::ModelGenerator.template :model_datamapper, :orm => :datamapper do
  source(File.dirname(__FILE__), "templates", "model.rb")
  destination("app/models", base_path, "#{file_name}.rb")
end
