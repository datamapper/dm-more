module DataMapper
  module Validations
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

        validates_acceptance_of :user_agreement, :allow_nil => false
        validates_acceptance_of :newsletter_signup
        validates_acceptance_of :privacy_agreement, :accept => %w(agreed accept), :message => "You must accept this agreement in order to proceed"
      end # BetaTesterAccount
    end
  end
end
