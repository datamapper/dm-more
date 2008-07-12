require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent.parent + 'spec_helper'

describe "EventDsl" do
  
  describe "event" do

    before(:each) do
      class Earth
        extend DataMapper::Is::StateMachine::EventDsl
        stub!(:state_machine_context?).and_return(true)
        stub!(:push_state_machine_context)
        stub!(:pop_state_machine_context)
      end
      machine = mock("machine", :events => [], :column => :state)
      Earth.instance_variable_set(:@is_state_machine, { :machine => machine })
    end

    it "declaration should succeed" do
      class Earth
        event :sunrise
      end
    end

  end
  
  describe "transitions" do

    before(:each) do

      class Earth
        extend DataMapper::Is::StateMachine::EventDsl

        stub!(:state_machine_context?).and_return(true)
        stub!(:push_state_machine_context)
        stub!(:pop_state_machine_context)
      end

      machine = mock("machine", :events => [], :column => :state)
      event = mock("sunrise_event")
      event.stub!(:add_transition)
      Earth.instance_variable_set(:@is_state_machine, {
        :machine => machine,
        :event   => { :name => :sunrise, :object => event }
      })
    end

    it "transitions definition should succeed" do
      class Earth
        transitions :from => :night, :to => :day
      end
    end

  end
  
end
