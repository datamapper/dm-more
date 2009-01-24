require 'rails_generator/base'

class DmInstallGenerator < Rails::Generator::Base

  def manifest
    record do |m|

      # Model, test, and fixture directories.
      m.directory "lib/tasks"

      # Model class, unit test, and fixtures.
      m.template "datamapper.rake",      "lib/tasks/datamapper.rake"
    end
  end

end
