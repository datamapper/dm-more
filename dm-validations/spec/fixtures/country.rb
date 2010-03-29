# -*- coding: utf-8 -*-

class Country
  #
  # Behaviors
  #

  include DataMapper::Resource

  #
  # Properties
  #

  property :id,         Serial
  property :name,       String

  property :area,       Integer

  #
  # Validations
  #

  validates_numericality_of :area, :message => "Please use integers to specify area"
end
