# -*- coding: utf-8 -*-

class City
  #
  # Behaviors
  #

  include DataMapper::Resource

  #
  # Properties
  #

  property :id,         Serial
  property :name,       String

  property :founded_in, Integer, :auto_validation => false

  #
  # Validations
  #

  validates_is_number :founded_in, :message => "Foundation year must be an integer"
end
