module DataMapper
  class Query
    attr_accessor :view, :key
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
          key = options.delete(:key)
          query = Query.new(repository, self, options)
          query.key = key
          query.view = '#{@name}'
          if Hash === options && options.has_key?(:repository)
            repository(options.delete(:repository)).read_many(query)
          else
            repository.read_many(query)
          end
        end
      EOS
    end
  end
end

module DataMapper
  module Model
    def view(name, body = nil)
      @views ||= Hash.new { |h,k| h[k] = {} }
      proc = View.new(self, name)
      @views[repository.name][name] = body
      proc
    end

    def views(repository_name = default_repository_name)
      @views ||= Hash.new { |h,k| h[k] = {} }
      @views[repository_name]
    end
  end
end
