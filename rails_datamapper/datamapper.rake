
# Monkey patch to allow overriding defined rake tasks (instead of
# adding to them, which is the default behaviour when specifying tasks
# >1 times).

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

def remove_task(task_name)
  returning Rake.application do |app|
    app.remove_task(app[task_name].name)
  end
end

# Until AR/DM co-existence becomes practically possible, presume
# mutual exclusivity between the two.  Thus we wipe all pre-existing
# db tasks which we assume to be ActiveRecord-based and thus won't
# work).

Rake.application.tasks.select do |t|
  t.class == Rake::Task && t.name.starts_with?("db")
end.each { |t| remove_task(t.name) }

namespace :db do

  desc 'Perform automigration'
  task :automigrate => :environment do
    FileList["app/models/**/*.rb"].each do |model|
      load model
    end
    ::DataMapper.auto_migrate!
  end

  desc 'Perform non destructive automigration'
  task :autoupgrade => :environment do
    FileList["app/models/**/*.rb"].each do |model|
      load model
    end
    ::DataMapper.auto_upgrade!
  end

  namespace :migrate do
    task :load => :environment do
      gem 'dm-migrations'
      FileList['db/migrations/*.rb'].each do |migration|
        load migration
      end
    end

    desc 'Migrate up using migrations'
    task :up, :version, :needs => :load do |t, args|
      version = args[:version]
      migrate_up!(version)
    end

    desc 'Migrate down using migrations'
    task :down, :version, :needs => :load do |t, args|
      version = args[:version]
      migrate_down!(version)
    end
  end

  desc 'Migrate the database to the latest version'
  task :migrate => 'db:migrate:up'

  namespace :sessions do
    desc "Creates the sessions table for DataMapperStore"
    task :create => :environment do
      ::DataMapperStore::Session.auto_migrate!
    end

    desc "Clear the sessions table for DataMapperStore"
    task :clear => :environment do
      ::DataMapperStore::Session.all.destroy!
    end
  end
end
