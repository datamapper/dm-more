module DataMapper
  class Collection
    attr_accessor :total_rows
  end
end

module DataMapper
  module CouchResource

    def self.included(mod)

      mod.class_eval do
        include DataMapper::Resource
        include DataMapper::CouchResource::Attachments

        property :id, String, :key => true, :field => :_id
        property :rev, String, :field => :_rev
        property :attachments, DataMapper::Types::JsonObject, :field => :_attachments

        def self.default_repository_name
          :couch
        end

        class << self

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
    end

  end
end