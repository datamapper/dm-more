require 'spec_helper'

try_spec do

  require './spec/fixtures/software_package'

  describe DataMapper::Types::Fixtures::SoftwarePackage do
    describe 'with source path at /var/cache/apt/archives/linux-libc-dev_2.6.28-11.40_i386.deb' do
      before :all do
        @source_path = '/var/cache/apt/archives/linux-libc-dev_2.6.28-11.40_i386.deb'
        @resource    = DataMapper::Types::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when is a new record' do
        before :all do
        end

        it 'points to original path' do
          @resource.source_path.to_s.should == @source_path
        end

        it 'responds to :directory?' do
          @resource.source_path.should respond_to(:directory?)
        end

        it 'responds to :file?' do
          @resource.source_path.should respond_to(:file?)
        end

        it 'responds to :dirname' do
          @resource.source_path.should respond_to(:dirname)
        end

        it 'responds to :absolute?' do
          @resource.source_path.should respond_to(:absolute?)
        end

        it 'responds to :readable?' do
          @resource.source_path.should respond_to(:readable?)
        end

        it 'responds to :size' do
          @resource.source_path.should respond_to(:size)
        end
      end
    end

    describe 'with destination path at /usr/local' do
      before :all do
        @destination_path = '/usr/local'
        @resource         = DataMapper::Types::Fixtures::SoftwarePackage.new(:destination_path => @destination_path)
      end

      describe 'when saved and reloaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'points to original path' do
          @resource.destination_path.to_s.should == @destination_path
        end

        it 'responds to :directory?' do
          @resource.destination_path.should respond_to(:directory?)
        end

        it 'responds to :file?' do
          @resource.destination_path.should respond_to(:file?)
        end

        it 'responds to :dirname' do
          @resource.destination_path.should respond_to(:dirname)
        end

        it 'responds to :absolute?' do
          @resource.destination_path.should respond_to(:absolute?)
        end

        it 'responds to :readable?' do
          @resource.destination_path.should respond_to(:readable?)
        end

        it 'responds to :size' do
          @resource.destination_path.should respond_to(:size)
        end
      end
    end

    describe 'with no (nil) source path' do
      before :all do
        @source_path = nil
        @resource    = DataMapper::Types::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when saved and reloaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'has nil source path' do
          @resource.source_path.should be_nil
        end
      end
    end

    describe 'with a blank source path' do
      before :all do
        @source_path = ''
        @resource    = DataMapper::Types::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when saved and reloaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'has nil source path' do
          @resource.source_path.should be_nil
        end
      end
    end

    describe 'with a source path assigned to an empty array' do
      before :all do
        @source_path = []
        @resource    = DataMapper::Types::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when saved and reloaded' do
        before :all do
          @resource.save.should be_true
          @resource.reload
        end

        it 'has nil source path' do
          @resource.source_path.should be_nil
        end
      end
    end

    describe 'with a source path assigned to a Hash' do
      before :all do
        @source_path = { :guitar => 'Joe Satriani' }
      end

      describe 'when instantiated' do
        it 'raises an exception' do
          lambda do
            DataMapper::Types::Fixtures::SoftwarePackage.new(:source_path => @source_path)
          end.should raise_error(TypeError)
        end
      end
    end
  end
end
