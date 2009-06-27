This is a Rails plugin that provides datamapper as an orm

== Setup

add the following line to your projects environment.rb

config.gem "rails_datamapper"

== Generators

This will install the datamapper rake tasks:

script/generate dm_install

Three generators are added by default

script/generate dm_model
script/generate rspec_dm_model
script/generate dm_migration

The first two add a migration but you can call

script/generate dm_model --skip-migration
script/generate rspec_dm_model --skip-migration

To avoid any dependency on active record add this to your projects environment.rb

config.frameworks -= [ :active_record ]
