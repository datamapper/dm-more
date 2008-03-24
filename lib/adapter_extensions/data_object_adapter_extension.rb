require File.dirname(__FILE__) + '/sqlite3_adapter_extension'

module AdapterExtensions
  module DataObjectsAdapterExtension

    def table(name)
      raise NotImplementedError
    end

  end
end
DataMapper::Adapters::DataObjectsAdapter.send(:include, AdapterExtensions::DataObjectsAdapterExtension)
