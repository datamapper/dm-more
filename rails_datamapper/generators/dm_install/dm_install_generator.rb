require 'rails_generator/base'

class DmInstallGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory "lib/tasks"
      m.template "datamapper.rake",      "lib/tasks/datamapper.rake"
    end
  end

end
