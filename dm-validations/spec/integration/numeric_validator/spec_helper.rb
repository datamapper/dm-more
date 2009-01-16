# -*- coding: utf-8 -*-
class BasketballPlayer
  #
  # Behavior
  #

  include DataMapper::Resource

  #
  # Properties
  #

  property :id,     Integer, :serial => true
  property :name,   String

  property :height, Float, :auto_validation => false
  property :weight, Float, :auto_validation => false

  #
  # Validations
  #

  validates_is_number :height, :weight
end

BasketballPlayer.auto_migrate!
