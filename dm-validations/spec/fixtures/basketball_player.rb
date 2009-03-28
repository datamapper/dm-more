# -*- coding: utf-8 -*-

class BasketballPlayer
  #
  # Behaviors
  #

  include DataMapper::Resource

  #
  # Properties
  #

  property :id,     Serial
  property :name,   String

  property :height, Float, :auto_validation => false
  property :weight, Float, :auto_validation => false

  #
  # Validations
  #

  validates_is_number :height, :weight
end
BasketballPlayer.auto_migrate!
