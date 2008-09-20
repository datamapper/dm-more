require 'base64'
require 'dm-types'
require 'net/http'

module DataMapper
  module Resource
    def add_attachment(name, content_type, data)

      unless (model.properties.has_property?(:attachments) &&
        model.properties[:attachments].type == DataMapper::Types::JsonObject &&
        model.properties[:attachments].field == :_attachments)
        raise ArgumentError, "Attachments require '  property :attachments, JsonObject, :field => :_attachments'"
      end

      if new_record? || !model.properties.has_property?(:rev)
        self.attachments ||= {}
        self.attachments[name] = {
          'content_type' => content_type,
          'data' => Base64.encode64(data).chomp
        }
      else
        http = Net::HTTP.new(repository.adapter.uri.host, repository.adapter.uri.port)
        uri = "/#{repository.adapter.escaped_db_name}/#{self.id}/#{name}?rev=#{self.rev}"
        headers = {
          'Content-Length' => data.size.to_s,
          'Content-Type' => content_type
        }
        response, data = http.put(uri, data, headers)
        self.reload
      end

    end

    def delete_attachment(name)

      unless (model.properties.has_property?(:attachments) &&
        model.properties[:attachments].type == DataMapper::Types::JsonObject &&
        model.properties[:attachments].field == :_attachments)
        raise ArgumentError, "Attachments require '  property :attachments, JsonObject, :field => :_attachments'"
      end

      if new_record?
        self.attachments.delete(name)
        self.attachments = nil if self.attachments.empty?
        return true
      end

      return false unless self.attachments && self.attachments[name]

      http = Net::HTTP.new(repository.adapter.uri.host, repository.adapter.uri.port)
      uri = "/#{repository.adapter.escaped_db_name}/#{self.id}/#{name}?rev=#{self.rev}"
      response, data = http.delete(uri, { 'Content-Type' => self.attachments[name]['content_type'] })

      return false unless response.kind_of?(Net::HTTPSuccess)

      self.attachments.delete(name)
      self.attachments = nil if self.attachments.empty?
      true
    end

    # TODO: cache data on model? (don't want to make resource dirty though...)
    def get_attachment(name)

      unless (model.properties.has_property?(:attachments) &&
        model.properties[:attachments].type == DataMapper::Types::JsonObject &&
        model.properties[:attachments].field == :_attachments)
        raise ArgumentError, "Attachments require '  property :attachments, JsonObject, :field => :_attachments'"
      end

      return nil unless self.id && self.attachments && self.attachments[name]

      http = Net::HTTP.new(repository.adapter.uri.host, repository.adapter.uri.port)
      uri = "/#{repository.adapter.escaped_db_name}/#{self.id}/#{name}"
      response, data = http.get(uri, { 'Content-Type' => self.attachments[name]['content_type'] })

      return nil unless response.kind_of?(Net::HTTPSuccess)

      data
    end
  end
end