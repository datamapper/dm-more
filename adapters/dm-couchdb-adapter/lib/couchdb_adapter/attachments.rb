require 'base64'
require 'mime/types'
require 'net/http'

module DataMapper
  module Resource
    def add_attachment(file, options = {})

      unless (model.properties.has_property?(:attachments) &&
        model.properties[:attachments].type == DataMapper::Types::JsonObject &&
        model.properties[:attachments].field == :_attachments)
        raise ArgumentError, "Attachments require '  property :attachments, JsonObject, :field => :_attachments'"
      end

      filename = File.basename(file.path)
      mime_types = MIME::Types.of(filename)
      options[:content_type] ||= mime_types.empty? ? 'application/octet-stream' : mime_types.first.content_type
      data = file.read
      options[:name] ||= filename

      if new_record? || !model.properties.has_property?(:rev)
        self.attachments ||= {}
        self.attachments[options[:name]] = {
          'content_type' => options[:content_type],
          'data' => Base64.encode64(data).chomp
        }
      else
        http = Net::HTTP.new(repository.adapter.uri.host, repository.adapter.uri.port)
        uri = "/#{repository.adapter.escaped_db_name}/#{self.id}/#{options[:name]}?rev=#{self.rev}"
        headers = {
          'Content-Length' => data.size.to_s,
          'Content-Type' => options[:content_type]
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

      unless self.attachments && self.attachments[name]
        false
      else
        response = nil
        unless new_record?
          http = Net::HTTP.new(repository.adapter.uri.host, repository.adapter.uri.port)
          uri = "/#{repository.adapter.escaped_db_name}/#{self.id}/#{name}?rev=#{self.rev}"
          response, data = http.delete(uri, { 'Content-Type' => self.attachments[name]['content_type'] })
        end

        if response && !response.kind_of?(Net::HTTPSuccess)
          false
        else
          self.attachments.delete(name)
          self.attachments = nil if self.attachments.empty?
          true
        end
      end
    end

    # TODO: cache data on model? (don't want to make resource dirty though...)
    def get_attachment(name)

      unless (model.properties.has_property?(:attachments) &&
        model.properties[:attachments].type == DataMapper::Types::JsonObject &&
        model.properties[:attachments].field == :_attachments)
        raise ArgumentError, "Attachments require '  property :attachments, JsonObject, :field => :_attachments'"
      end

      unless self.id && self.attachments && self.attachments[name]
        nil
      else
        http = Net::HTTP.new(repository.adapter.uri.host, repository.adapter.uri.port)
        uri = attachment_path(name)
        response, data = http.get(uri, { 'Content-Type' => self.attachments[name]['content_type'] })

        unless response.kind_of?(Net::HTTPSuccess)
          nil
        else
          data
        end
      end

    end

    def attachment_path(name)
      if new_record?
        nil
      else
        "/#{repository.adapter.escaped_db_name}/#{self.id}/#{name}"
      end
    end
  end
end
