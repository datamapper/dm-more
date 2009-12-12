require 'spec_helper'

module IPAddressMatchers
  def run_ipv6
    simple_matcher('run IPv6') { |model| model.runs_ipv6? }
  end

  def run_ipv4
    simple_matcher('run IPv4') { |model| model.runs_ipv4? }
  end
end

try_spec do

  require './spec/fixtures/network_node'

  describe DataMapper::Types::Fixtures::NetworkNode do
    before :all do
      @resource = DataMapper::Types::Fixtures::NetworkNode.new(
        :node_uuid        => '25a44800-21c9-11de-8c30-0800200c9a66',
        :ip_address       => nil,
        :cidr_subnet_bits => nil
      )
    end

    include IPAddressMatchers

    describe 'with IP address fe80::ab8:e8ff:fed7:f8c9' do
      before :all do
        @resource.ip_address = 'fe80::ab8:e8ff:fed7:f8c9'
      end

      describe 'when dumped and loaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'is an IPv6 node' do
          @resource.should run_ipv6
        end
      end
    end

    describe 'with IP address 127.0.0.1' do
      before :all do
        @resource.ip_address = '127.0.0.1'
      end

      describe 'when dumped and loaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'is an IPv4 node' do
          @resource.should run_ipv4
        end
      end
    end

    describe 'with IP address 218.43.243.136' do
      before :all do
        @resource.ip_address = '218.43.243.136'
      end

      describe 'when dumped and loaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'is an IPv4 node' do
          @resource.should run_ipv4
        end
      end
    end

    describe 'with IP address 221.186.184.68' do
      before :all do
        @resource.ip_address = '221.186.184.68'
      end

      describe 'when dumped and loaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'is an IPv4 node' do
          @resource.should run_ipv4
        end
      end
    end

    describe 'with IP address given as CIDR' do
      before :all do
        @resource.ip_address = '218.43.243.0/24'
      end

      describe 'when dumped and loaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'is an IPv4 node' do
          @resource.should run_ipv4
        end

        it 'includes IP address 218.43.243.2 in subnet hosts' do
          @resource.ip_address.include?('218.43.243.2')
        end
      end
    end

    describe 'with a blank string used as IP address' do
      before :all do
        @resource.ip_address = ''
      end

      describe 'when dumped and loaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'is an IPv4 node' do
          @resource.should run_ipv4
        end

        it 'should be the expected value' do
          @resource.ip_address.should == IPAddr.new('0.0.0.0')
        end
      end
    end

    describe 'with NO IP address' do
      before :all do
        @resource.ip_address = nil
      end

      describe 'when dumped and loaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'has no IP address assigned' do
          @resource.ip_address.should be_nil
        end
      end
    end
  end
end
