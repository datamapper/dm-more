begin
  gem 'dm-core', '=0.9.5'
  require 'dm-core'
rescue LoadError => e
  require 'data_mapper'
end

require 'base64'
module Merb
  module SessionMixin
    def setup_session
      before_value = cookies[_session_id_key]
      request.session, cookies[_session_id_key] = Merb::DataMapperSession.persist(cookies[_session_id_key])
      @_fingerprint = Marshal.dump(request.session.data).hash
      @_new_cookie = cookies[_session_id_key] != before_value
    end

    def finalize_session
      request.session.save if @_fingerprint != Marshal.dump(request.session.data).hash
      set_cookie(_session_id_key, request.session.session_id, Time.now + _session_expiry) if (@_new_cookie || request.session.needs_new_cookie)
    end

    def session_store_type
      "datamapper"
    end
  end

  table_name = (Merb::Plugins.config[:merb_datamapper][:session_table_name] || "sessions")

  class DataMapperSession
    include DataMapper::Resource

    storage_names[:default] = "sessions"
    property :session_id, String, :length => 255, :lazy => false, :key => true
    property :data,       Text, :lazy => false
    property :updated_at, DateTime

    attr_accessor :needs_new_cookie

    class << self
      # Generates a new session ID and creates a row for the new session in the database.
      def generate
        new_session = self.new(:data =>{})
        new_session.session_id = Merb::SessionMixin::rand_uuid
        new_session.save
        new_session
      end

      # Gets the existing session based on the <tt>session_id</tt> available in cookies.
      # If none is found, generates a new session.
      def persist(session_id)
        if !session_id.blank?
          session = self.first :session_id => session_id
        end
        unless session
          session = generate
        end
        [session, session.session_id]
      end

      def marshal(data) Base64.encode64(Marshal.dump(data)) if data end
      def unmarshal(data) Marshal.load(Base64.decode64(data)) if data end
    end

    # Regenerate the Session ID
    def regenerate
      self.session_id = Merb::SessionMixin::rand_uuid
      self.needs_new_cookie = true
      self.save
    end

    # Recreates the cookie with the default expiration time
    # Useful during log in for pushing back the expiration date
    def refresh_expiration
      self.needs_new_cookie = true
    end

    # Lazy-delete of session data
    def delete(key = nil)
      key ? self.data.delete(key) : self.data.clear
    end

    def empty?
      data.empty?
    end

    def each(&b)
      data.each(&b)
    end

    def each_with_index(&b)
      data.each_with_index(&b)
    end

    def [](key)
      data[key]
    end

    def []=(key, val)
      data[key] = val
    end

    def data
      @unmarshalled_data ||= self.class.unmarshal(@data) || {}
    end

    def data=(data)
      @data, @unmarshalled_data = data, data
    end

  private

    before :save, :serialize_data

    def serialize_data
      attribute_set :data, self.class.marshal(self.data)
    end
  end
end
