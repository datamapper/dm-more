require 'dm-core'

# Implements DataMapper-specific session store.

module ActionController
  module Session
    class DataMapperStore < AbstractStore

      # Options passed in here are specified at:
      # config/initializers/session_store.rb

      def initialize(app, options = {})
        options.symbolize_keys!
        options[:expire_after] = options[:expires] || nil

        super

        unless (self.class.class_variable_defined? :@@session_class and @@session_class)
          @@session_class = options.delete(:session_class) || ::DataMapperStore::Session
        end
      end

      private
      def get_session(env, sid)
        sid     ||= generate_sid
        session   = @@session_class.first(:session_id => sid)
        [sid, session.nil? ? {} : session.data]
      end

      def set_session(env, sid, session_data)
        session            = @@session_class.first(:session_id => sid) ||
                             @@session_class.new(:session_id => sid)
        session.data       = session_data || {}
        session.updated_at = Time.now if session.dirty?

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
    property :session_id, String,   :unique_index => true
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
