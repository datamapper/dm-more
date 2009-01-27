This is a Rails plugin that provides datamapper as an orm

== Setup

add the following line to your projects environment.rb

config.gem "rails_datamapper"

== Generators

This will install the datamapper rake tasks:

script/generate dm_install

Two generators are added by default

script/generate dm_model
script/generate rspec_dm_model

These by default add an active record migrations but you can call

script/generate dm_model --skip-migration
script/generate rspec_dm_model --skip-migration

To avoid any dependency on active record add this to your projects environment.rb

config.frameworks -= [ :active_record ]

== Future
I really should sort out migrations but with rails3 round the corner don't hold your breath
