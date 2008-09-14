This is a datamapper adapter to couchdb.

== Setup
Install with the rest of the dm-more package, using:
  gem install dm-more

Then when initializing datamapper:
  - adapter should be :couchdb
  - database should be the name of the couch adapter
  - host (probably localhost)
  - port should be specified (couchdb defaults to port 5984)

You should now be able to use resources and their properties and have them stored to couchdb.
NOTE: 'couchdb_type' is a reserved property, used to map documents to their ruby models.

== Views
Special consideration has been made to help work with couch views.  You can define them in the model using the view function and then use Model.auto_migrate! to add the views for Model to the database, or DataMapper.auto_migrate! to add the views for all models to the database.

An example class with views defined:

class User
  include DataMapper::Resource

  property :name, String
  view :by_name, { "map" => "function(doc) { if (doc.couchdb_type == 'user') { emit(doc.name, doc); } }" }
end

You could then call User.by_name to get a listing of users ordered by name, or pass a key to try and find a specific user by their name, ie User.by_name(:key => 'username').
