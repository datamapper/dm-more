module Merb::Orms::DataMapper::Resource
  def to_param
    key
  end
end
DataMapper::Resource.send(:include, Merb::Orms::DataMapper::Resource)
