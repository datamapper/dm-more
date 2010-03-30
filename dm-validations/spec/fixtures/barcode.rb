module DataMapper
  module Validations
    module Fixtures
      class Barcode
        attr_accessor :valid_hook_call_count

        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        without_auto_validations do
          property :code, String, :key => true
        end

        #
        # Validations
        #

        validates_length_of :code, :max => 10

        def self.valid_instance
          new(:code => "3600029145")
        end

        # measure the number of times #valid? is executed
        before :valid? do
          @valid_hook_call_count ||= 0
          @valid_hook_call_count += 1
        end

      end # Barcode
    end
  end
end
