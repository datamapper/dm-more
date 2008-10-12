module DataMapper
  module CouchResource

    def self.included(mod)
      mod.class_eval do
        include DataMapper::Resource

        property :id, String, :key => true, :field => :_id
        property :rev, String, :field => :_rev
        property :attachments, DataMapper::Types::JsonObject, :field => :_attachments

        def self.default_repository_name
          :couch
        end

      end
    end

  end
end