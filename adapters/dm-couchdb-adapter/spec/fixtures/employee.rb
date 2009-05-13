require Pathname(__FILE__).dirname + 'person'

class Employee < Person
  property :rank, String
end
