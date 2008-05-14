require 'fileutils'

namespace :dm do

  task :merb_start do
    Merb.start_environment :adapter => 'runner',
                           :environment => ENV['MERB_ENV'] || 'development'
  end

  namespace :db do
    desc "Perform automigration"
    task :automigrate => :merb_start do
      ::DataMapper::AutoMigrator.auto_migrate
    end
    desc "Perform non destructive automigration"
    task :autoupgrade => :merb_start do
      ::DataMapper::AutoMigrator.auto_upgrade
    end
  end

  namespace :sessions do
    desc "Perform automigration for sessions"
    task :create => :merb_start do
      Merb::DataMapperSession.auto_migrate!
    end

    desc "Clears sessions"
    task :clear => :merb_start do
      table_name = ((Merb::Plugins.config[:datamapper] || {})[:session_table_name] || "sessions")
      ::DataMapper.repository.adapter.execute("DELETE FROM #{table_name}")
    end
  end
end
