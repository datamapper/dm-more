Merb::Generators::MigrationGenerator.template :migration_datamapper, :orm => :datamapper do
  source(File.dirname(__FILE__), 'templates/migration.rb')
  destination("#{destination_directory}/#{file_name}.rb")
end
