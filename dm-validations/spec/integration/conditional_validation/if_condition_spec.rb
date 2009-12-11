require 'spec_helper'
require 'integration/conditional_validation/spec_helper'

describe 'DataMapper::Validate::Fixtures::UDPPacket' do
  before :all do
    DataMapper::Validate::Fixtures::UDPPacket.auto_migrate!

    @model = DataMapper::Validate::Fixtures::UDPPacket.new
  end

  describe "that is transported encapsulated into IPv4 packet" do
    before :all do
      @model.underlying_ip_version = 4
    end

    describe "and has no checksum" do
      before :all do
        @model.checksum = nil
      end

      it_should_behave_like "valid model"
    end

    describe "and has no checksum algorithm" do
      before :all do
        @model.checksum_algorithm = nil
      end

      it_should_behave_like "valid model"
    end
  end


  describe "that is transported encapsulated into IPv6 packet" do
    before :all do
      @model.underlying_ip_version = 6
    end

    describe "and has no checksum" do
      before :all do
        @model.checksum = nil
      end

      it_should_behave_like "invalid model"

      it "has a meaningful error message" do
        @model.errors.on(:checksum).should == [ 'Checksum is mandatory when used with IPv6' ]
      end
    end

    describe "and has no checksum algorithm" do
      before :all do
        @model.checksum_algorithm = nil
      end

      it_should_behave_like "invalid model"

      it "has a meaningful error message" do
        @model.errors.on(:checksum_algorithm).should == [ 'Checksum is mandatory when used with IPv6' ]
      end
    end
  end
end
