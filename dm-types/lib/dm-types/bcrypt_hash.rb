require 'dm-core'
require 'bcrypt'

module DataMapper
  module Types
    class BCryptHash < DataMapper::Type
      primitive String
      length    60

      def self.load(value, property)
        typecast(value, property)
      end

      def self.dump(value, property)
        typecast(value, property)
      end

      def self.typecast(value, property)
        if value.nil?
          nil
        else
          begin
            value.is_a?(BCrypt::Password) ? value : BCrypt::Password.new(value)
          rescue BCrypt::Errors::InvalidHash
            BCrypt::Password.create(value, :cost => BCrypt::Engine::DEFAULT_COST)
          end
        end
      end
    end # class BCryptHash
  end # module Types
end # module DataMapper

# The Bcrypt::Password#hash method returns a String and not an Integer,
# which is required by any ruby class that uses a Hash underneath. Removing
# this method does not cause any spec failures in Bcrypt::Password
BCrypt::Password.class_eval { remove_method :hash }
