require 'spec_helper'

describe "InvalidStates" do

  it "should get InvalidContext when requiring" do
    lambda {
      require 'examples/invalid_states'
    }.should raise_error(DataMapper::Is::StateMachine::InvalidContext)
  end

end
