require 'spec_helper'

describe "StateMachine" do

  describe "is_state_machine" do

    before(:each) do
      class Earth
        extend DataMapper::Is::StateMachine

        stub!(:properties).and_return([])
        stub!(:property)
        stub!(:before)

        stub!(:state_machine_context?).and_return(true)
        stub!(:push_state_machine_context)
        stub!(:pop_state_machine_context)
      end
    end

    it "declaration should succeed" do
      class Earth
        is_state_machine
      end
    end

  end
end
