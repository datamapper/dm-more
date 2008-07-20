class Book < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :author
  
  belongs_to :shelf
end
