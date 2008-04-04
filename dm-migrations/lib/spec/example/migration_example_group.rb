require 'spec'

module Spec
  module Example
    class MigrationExampleGroup < Spec::Example::ExampleGroup

      before(:all) do
        # drop & create db
        run_prereq_migrations
      end

      before(:each) do
        run_migration
      end

      after(:all) do
        # drop db
      end

      def run_prereq_migrations
        @@migrations.sort.each do |migration|
          break if migration.name.to_s == migration_name.to_s
          migration.perform_up
        end
      end

      def run_migration
        @@migrations.sort.each do |migration|
          migration.perform_up if migration.name.to_s == migration_name
        end
      end
      
      def migration_name
        @migration_name ||= self.class.instance_variable_get("@description_text").to_s
      end

      Spec::Example::ExampleGroupFactory.register(:migration, self)

    end
  end
end

