require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

# global first, then local to length validators
require __dir__.parent.parent + "spec_helper"
require __dir__ + 'spec_helper'

# FIXME: these oldish spec examples are messy and need to be organize
# like the rest of new spec suite
describe DataMapper::Validate::LengthValidator do
  it "lets user specify a maximum length of a string field" do
    class ::DataMapper::Validate::Fixtures::MotorLaunch
      validators.clear!
      validates_length :name, :max => 5
    end

    launch = DataMapper::Validate::Fixtures::MotorLaunch.new
    launch.name = 'a' * 6
    launch.should_not be_valid
    launch.errors.on(:name).should include('Name must be less than 5 characters long')
  end

  it "aliases :maximum for :max" do
    class ::DataMapper::Validate::Fixtures::MotorLaunch
      validators.clear!
      validates_length :name, :maximum => 5
    end
    launch = DataMapper::Validate::Fixtures::MotorLaunch.new
    launch.name = 'a' * 6
    launch.should_not be_valid
    launch.errors.on(:name).should include('Name must be less than 5 characters long')
  end
end
