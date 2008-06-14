# This provides a mechanism for accessing stored and indexed views
# in the CouchDB database.
#
# Here's a sample model:
#
#   class User
#     include DataMapper::Resource
#
#     property :id, String, :key => true, :field => :_id
#     property :rev, String, :field => :_rev
#
#     view :by_name
#   end
#
# And here's the DM code to generate the view:
#
#   view = Net::HTTP::Put.new("/example_db/_design/users")
#   view["content-type"] = "text/javascript"
#   view.body = {
#     "language" => "text/javascript",
#     "views" => {
#       "by_name" => "function(doc) { map(doc.name, doc); }"
#     }
#   }.to_json
#   @adapter.send(:request, false) do |http|
#     http.request(view)
#   end
#

module DataMapper
  class Repository
    def view(model, name, options = {})
      adapter.view(model, name, options)
    end
  end
end

module DataMapper
  module Adapters
    class AbstractAdapter
      def view(resource, proc_name, options = {})
        raise NotImplementedError
      end
    end
  end
end

module DataMapper
  class View
    attr_reader :model, :name

    def initialize(model, name)
      @model = model
      @name = name

      create_getter
    end

    def create_getter
      @model.class_eval <<-EOS, __FILE__, __LINE__
        def self.#{@name}(options = {})
          if Hash === options && options.has_key?(:repository)
            repository(options.delete(:repository)).view(self, :#{@name}, options)
          else
            repository.view(self, :#{@name}, options)
          end
        end
      EOS
    end
  end
end

module DataMapper
  module Resource
    module ClassMethods
      def view(name)
        @views ||= Hash.new { |h,k| h[k] = {} }
        proc = View.new(self, name)
        @views[repository.name][name] = proc
        proc
      end

      def views(repository_name = default_repository_name)
        @views[repository_name]
      end
    end
  end
end
