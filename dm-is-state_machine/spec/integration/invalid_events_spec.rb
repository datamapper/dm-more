require 'spec_helper'

describe "InvalidEvents" do

  it "should get InvalidContext when requiring" do
    lambda {
      require 'examples/invalid_events'
    }.should raise_error(DataMapper::Is::StateMachine::InvalidContext)
  end

end
