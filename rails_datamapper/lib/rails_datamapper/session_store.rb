require 'dm-core'

# Implements DataMapper-specific session store.  Some code/ideas
# ganked from both Rails and datamapper4rails.

module ActionController
  module Session
    class DataMapperStore < AbstractStore

      # Options passed in here are specified at:
      # config/initializers/session_store.rb

      def initialize(app, options = {})
        options.symbolize_keys!
        options[:expire_after] = options[:expires_in] || nil

        super

        if options.delete(:cache)
          @@cache = {}
        else
          @@cache = nil unless self.class.class_variable_defined? :@@cache
        end

        unless (self.class.class_variable_defined? :@@session_class and @@session_class)
          @@session_class = options.delete(:session_class) || ::DataMapperStore::Session
        end
      end

      private
      def get_session(env, sid)
        sid     ||= generate_sid
        session   = @@cache && @@cache[sid] || @@session_class.get(sid)
        [sid, session.nil? ? {} : session.data]
      end

      def set_session(env, sid, session_data)
        session            = @@cache && @@cache[sid] || @@session_class.get(sid) || @@session_class.new(:session_id => sid)
        session.data       = session_data || {}
        session.updated_at = Time.now if session.dirty?

        @@cache[sid] = session if @@cache

        session.save
      end
    end
  end
end

module DataMapperStore
  class Session
    include ::DataMapper::Resource

    def self.name
      "session"
    end

    property :id,         Serial
    property :session_id, String,   :key => true
    property :data,       Text,     :nullable => false, :default => ::Base64.encode64(Marshal.dump({}))
    property :updated_at, DateTime, :nullable => true, :index => true

    def data=(data)
      attribute_set(:data, ::Base64.encode64(Marshal.dump(data)))
    end

    def data
      Marshal.load(::Base64.decode64(attribute_get(:data)))
    end
  end
end

