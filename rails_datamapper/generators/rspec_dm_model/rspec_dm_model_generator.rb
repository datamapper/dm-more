require 'rails_generator/generators/components/model/model_generator'
require 'active_record'

class RspecDmModelGenerator <ModelGenerator

  def manifest
    record do |m|

      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Model, spec, and fixture directories.
      m.directory File.join('app/models',  class_path)
      m.directory File.join('spec/models', class_path)

      # Model class, spec and fixtures.
      m.template 'dm_model:model.rb', File.join('app/models',  class_path, "#{file_name}.rb")
      m.template 'model_spec.rb',     File.join('spec/models', class_path, "#{file_name}_spec.rb")

      unless options[:skip_migration]
        m.migration_template 'dm_migration:migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end

end
