
require 'bcrypt'

module DataMapper
  module Types
    class BCryptHash < DataMapper::Type
      primitive String
      size 60

      def self.load(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          BCrypt::Password.new(value)
        else
          raise ArgumentError.new("+value+ must be nil or a String")
        end
      end

      def self.dump(value, property)
        if value.nil?
          nil
        elsif value.is_a?(BCrypt::Password)
          value.to_s
        elsif value.is_a?(String)
          BCrypt::Password.create(value, :cost => BCrypt::Engine::DEFAULT_COST)
        else
          raise ArgumentError.new("+value+ must be nil, a String, or a BCrypt::Password object") 
        end
      end
 
      def self.typecast(value, property)
        if value.nil?
          nil
        else
          begin
            value.is_a?(BCrypt::Password) ? value : BCrypt::Password.new(value)
          rescue BCrypt::Errors::InvalidHash
            BCrypt::Password.create(value, :cost => BCrypt::Engine::DEFAULT_COST)
          rescue
           raise $1
          end
        end
      end
    end # class BCryptHash
  end # module Types
end # module DataMapper
