require File.dirname(__FILE__) + '/sqlite3_adapter_extension'

module AdapterExtensions
  module DataObjectAdapterExtenstion

    def table(name)
      raise NotImplementedError
    end

  end
end
DataMapper::Adapters::DataObjectAdapter.send(:include, AdapterExtensions::DataObjectAdapterExtenstion)
