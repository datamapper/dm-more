require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

# global first, then local to length validators
require __dir__.parent.parent + "spec_helper"
require __dir__ + 'spec_helper'

describe DataMapper::Validate::Fixtures::UDPPacket do
  before :all do
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
        @model.errors.on(:checksum).should include("Checksum is mandatory when used with IPv6")
      end
    end

    describe "and has no checksum algorithm" do
      before :all do
        @model.checksum_algorithm = nil
      end

      it_should_behave_like "invalid model"

      it "has a meaningful error message" do
        @model.errors.on(:checksum_algorithm).should include("Checksum is mandatory when used with IPv6")
      end
    end
  end
end
