require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Enum do
  before(:all) do
    class Bug
      include DataMapper::Resource

      property :id, Integer, :serial => true
      property :status, Enum[:crit, :warn, :info, :unknown]
    end
    Bug.auto_migrate!
  end

  it "should work" do
    repository(:default) do
      Bug.create!(:status => :crit)
      Bug.create!(:status => :warn)
    end
    bugs = Bug.all
    bugs[0].status.should == :crit
    bugs[1].status.should == :warn
  end
end
