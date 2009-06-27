require 'rails_generator/generators/components/model/model_generator'
require 'active_record'

class DmModelGenerator < ModelGenerator

  def manifest
    record do |m|

      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit',  class_path)

      # Model class, unit test, and fixtures.
      m.template 'model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'unit_test.rb',  File.join('test/unit',  class_path, "#{file_name}_test.rb")

      unless options[:skip_migration]
        m.migration_template 'dm_migration:migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end

end
