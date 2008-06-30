module Merb
  module Orms
    module DataMapper
      module Resource
        def to_param
          key
        end
      end
    end
  end
end
DataMapper::Resource.send(:include, Merb::Orms::DataMapper::Resource)
