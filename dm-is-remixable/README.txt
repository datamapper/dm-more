= dm-is-remixable

DataMapper::Is::Remixable allows you to create re-usable chunks of relational data, its kind of like multiple
inheritance for models.


For example:
#Comments are everywhere, why define them over and over?
module Comment
  include DataMapper::Resource
  is :remixable
  
  property :id,         Integer, :key => true, :serial => true
  property :body,       String
  property :created_at, DateTime
end

#Lots of things can be addressable; people, buildings
module Addressable
  include DataMapper::Resource
  
  is :remixable,
    :suffix => "address" #Default suffix is module name pluralized
  
  property :id,         Integer, :key => true, :serial => true
  
  property :label,      String #home, work, etc...
  
  property :address1,   String, :length => 255
  property :address2,   String, :length => 255
  
  property :city,       String, :length => 128
  property :state,      String, :length => 2
  property :zip,        String, :length => 5..10
end

module Vote
  include DataMapper::Resource
  
  is :remixable
  
  property :id,         Integer, :key => true, :serial => true
  property :opinion,    Enum.new("good","bad")
  
end

class Location
  include DataMapper::Resource
  
  #Location can have 1 address
  remix 1, Addressable
  
  # This does the following:
  # - creates a class called LocationAddress 
      (default name would be LocationAddressable, but Addressable#suffix was specified)
  # - duplicates the properties of Addressable within LocationAddress
  # - a table called location_addresses
  # - creates Location#location_addresses accessor
  
  #... methods, properties, etc ...#
end


class User
  include DataMapper::Resource
  
  #User can have many addresses
  remix n, Addressable, :accessor => "addresses"
  # - creates a class called UserAddress 
      (default name would be UserAddressable, but Addressable#suffix was specified)
  # - duplicates the properties of Addressable within UserAddress
  # - a table called user_addresses
  # - creates User#user_addresses accessor
  # - creates an accessor alias User#addresses
  
  enhance Addressable do
    storage_names[:default] = "a_different_table_name"
    property :label, Enum.new("work","home")
    
    #This adds a column to user_addresses to store an address label
  end
  
  #... methods, properties, etc ...#
end

class Article
  include DataMapper::Resource
  
  remix n, Comment, :for => User
  # - creates a class called ArticleComment
  # - duplicates the properties of Comment within ArticleComment
  # - a table called article_comments
  # - creates Article#article_comments
  # - creates User#article_comments
  
  #... methods, properties, etc ...#

end

class Video
  include DataMapper::Resource
  
  remix n, Comment, :for => User, :accessor => "comments"
  # - creates a class called VideoComment
  # - duplicates the properties of Comment within VideoComment
  # - a table called video_comments
  # - creates Video#video_comments
  # - creates User#video_comments
  # - create Video#comments
  
  enhance Comment do
    # VideoComment now has the method #reverse
    def reverse
      return self.body.reverse
    end
    
    #I like YouTubes ability for users to vote comments up and down
    remix 1, Vote, :for => User
    # - creates a class called VideoCommentVote
    # - duplicates the properties of Vote within VideoCommentVote
    # - a table called video_comment_votes
    # - creates Video#video_comments#votes
    
  end
  
  #... methods, properties, etc ...#
end
