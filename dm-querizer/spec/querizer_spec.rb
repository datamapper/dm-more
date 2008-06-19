require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Qutery' do
    class User
      include DataMapper::Resource

      property :id, Serial
      property :name, String
      property :age, Integer
      property :rating, Integer
      
      auto_migrate!
    end
    
    User.create(:name => 'john', :age => 40)
    User.create(:name => 'john', :age => 41)
    User.create(:name => 'john', :age => 42)

    User.all(:name => 'john', :age.gt => 20)

    User.all{name == 'john' && age > 20}
    
    #User.all{name == 'john' && age > (rating + 10)}
    
    #User.all{right == left + 1}


  end
end