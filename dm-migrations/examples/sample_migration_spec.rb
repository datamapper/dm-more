require File.dirname(__FILE__) + '/sample_migration'
require File.dirname(__FILE__) + '/../lib/spec/example/migration_example_group.rb'

describe :create_people_table, :type => :migration do

  before(:all) do
    puts "Inserts here"
  end

  it 'should do something' do
    puts "hi"
  end

end
