require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

require 'pp'
describe DataMapper::Types::Enum do
  before(:all) do
    class Bug
      include DataMapper::Resource

      def self.default_repository_name; :sqlite3 end

      property :id, Integer, :serial => true
      property :status, Enum[:crit, :warn, :info, :unknown]
    end
    Bug.auto_migrate!(:sqlite3)
  end

  it "should work" do
    repository(:sqlite3) do
      Bug.create!(:status => :crit)
      Bug.create!(:status => :warn)
    end
    bugs = Bug.all
    Bug.all.each do |b|
      pp b
      # <Bug status = :crit, id = 1>
      # <Bug status = :warn, id = 2>
    end
    bugs[0].status.should == :crit
    bugs[1].status.should == :warn
  end
end
