class Shelf < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :books
end
