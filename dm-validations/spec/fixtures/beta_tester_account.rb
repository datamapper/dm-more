module DataMapper
  module Validate
    module Fixtures
      class BetaTesterAccount
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,             Serial
        property :full_name,      String, :auto_validation => false
        property :email,          String, :auto_validation => false

        property :user_agreement,    Boolean, :auto_validation => false
        property :newsletter_signup, String,  :auto_validation => false
        property :privacy_agreement, String,  :auto_validation => false

        #
        # Validations
        #

        validates_is_accepted :user_agreement, :allow_nil => false
        validates_is_accepted :newsletter_signup
        validates_is_accepted :privacy_agreement, :accept => %w(agreed accept), :message => "You must accept this agreement in order to proceed"
      end # BetaTesterAccount
    end
  end
end
