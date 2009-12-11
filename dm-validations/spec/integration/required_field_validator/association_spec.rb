require 'spec_helper'
require 'integration/required_field_validator/spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  class Artist
    #
    # Behaviors
    #

    include DataMapper::Resource

    #
    # Properties
    #

    property :id,   Serial
    property :name, String,  :auto_validation => false

    #
    # Associations
    #

    has n, :albums

    #
    # Validations
    #

    validates_present :name
  end

  class Album
    #
    # Behaviors
    #

    include DataMapper::Resource

    #
    # Properties
    #

    property :id,        Serial
    property :name,      String,  :auto_validation => false
    property :artist_id, Integer, :index => :artist

    #
    # Associations
    #

    belongs_to :artist

    #
    # Validations
    #

    validates_present :name, :artist
  end
  Artist.auto_migrate!
  Album.auto_migrate!



  describe 'Album' do
    before :all do
      Artist.auto_migrate!
      Album.auto_migrate!
    end

    before do
      @artist = Artist.create(:name => "Oceanlab")
      @album  = @artist.albums.new(:name => "Sirens of the sea")
    end

    describe 'with a missing artist' do
      before do
        @album.artist = nil
      end

      it 'is not valid' do
        @album.should_not be_valid
      end

      it 'has a meaninful error messages on association key property' do
        @album.valid?
        @album.errors.on(:artist).should == [ 'Artist must not be blank' ]
      end
    end

    describe 'with specified artist and name' do
      before do
        # no op
      end

      it 'is valid' do
        @album.should be_valid
      end
    end
  end
end
