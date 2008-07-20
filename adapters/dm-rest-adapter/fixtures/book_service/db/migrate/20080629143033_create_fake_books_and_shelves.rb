class CreateFakeBooksAndShelves < ActiveRecord::Migration
  def self.up
    books = []
    books << Book.new(:title => "The Pragmatic Programmer", :author => "Dave Thomas")
    books << Book.new(:title => "Agile Web Development With Rails", :author => "Dave Thomas")    
    shelf = Shelf.new(:name => "Ruby Geekery")
    books.each { |book| shelf.books << book }
    shelf.save!
    
    books.clear
    books << Book.new(:title => "Kama Sutra", :author => "Who fucking knows")
    books << Book.new(:title => "Sex for Dummies", :author => "Some guy")
    shelf = Shelf.new(:name => "What geeks SHOULD be reading")
    books.each { |book| shelf.books << book }
    shelf.save!    
  end

  def self.down
  end
end
