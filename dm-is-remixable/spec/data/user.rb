require 'data/viewable'
require 'data/billable'
require 'data/addressable'
require 'data/rating'

class User

  include DataMapper::Resource

  property :id, Serial
  property :first_name, String, :nullable => false,  :length=> 2..50
  property :last_name, String, :nullable => false, :length => 2..50

  remix n, :viewables
  remix n, :billables, :model => "Account"
  remix n, :addressables
  remix n, :commentables, :as => "comments", :for => "User", :via => "commentor"
  remix n, "My::Nested::Remixable::Rating"

end
