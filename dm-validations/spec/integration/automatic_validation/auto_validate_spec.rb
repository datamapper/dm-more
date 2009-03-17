require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe "Automatic Validation from Property Definition" do
  it "should auto add a validates_format if the :format option is given" do
    # format test - format = /A\d{4}\z/   on code
    boat = SailBoat.new
    boat.should be_valid_for_format_test
    boat.code = 'A1234'
    boat.should be_valid_for_format_test
    boat.code = 'BAD CODE'
    boat.should_not be_valid_for_format_test
    boat.errors.on(:code).should include('Code has an invalid format')
  end

  it "should auto add range checking the length of a string while still allowing null values" do
    boat = SailBoat.new
    boat.allow_nil = 'ABC'
    boat.should_not be_valid_for_nil_test
    boat.errors.on(:allow_nil).should include('Allow nil must be between 5 and 10 characters long')

    boat.allow_nil = 'ABCDEFG'
    boat.should be_valid_for_nil_test

    boat.allow_nil = 'ABCDEFGHIJKLMNOP'
    boat.should_not be_valid_for_nil_test
    boat.errors.on(:allow_nil).should include('Allow nil must be between 5 and 10 characters long')

    boat.allow_nil = nil
    boat.should be_valid_for_nil_test
  end

  describe 'for non-nullable Boolean properties' do
    before do
      @boat = HasNotNullableBoolean.new(:id => 1)
    end

    it 'should allow true' do
      @boat.set(:bool => true)
      @boat.should be_valid
    end

    it 'should allow false' do
      @boat.set(:bool => false)
      @boat.should be_valid
    end

    it 'should not allow nil' do
      @boat.set(:bool => nil)
      @boat.should_not be_valid
      @boat.errors.on(:bool).should include('Bool must not be nil')
    end
  end

  describe 'for non-nullable ParanoidBoolean properties' do
    before do
      @boat = HasNotNullableParanoidBoolean.new(:id => 1)
    end

    it 'should allow true' do
      @boat.set(:bool => true)
      @boat.should be_valid
    end

    it 'should allow false' do
      @boat.set(:bool => false)
      @boat.should be_valid
    end

    it 'should not allow nil' do
      @boat.set(:bool => nil)
      @boat.should_not be_valid
      @boat.errors.on(:bool).should include('Bool must not be nil')
    end
  end

  { :float => Float, :big_decimal => BigDecimal }.each do |column, type|
    describe "for #{type} properties" do
      before do
        @boat = SailBoat.new(:id => 1)
      end

      it 'should allow integers' do
        @boat.set(column => 1)
        @boat.should be_valid
      end

      it 'should allow floats' do
        @boat.set(column => '1.0')
        @boat.should be_valid
      end

      it 'should allow decimals' do
        @boat.set(column => BigDecimal('1'))
        @boat.should be_valid
      end
    end
  end

  describe 'for within validator' do
    before :all do
      class ::LimitedBoat
        include DataMapper::Resource
        property :id,       DataMapper::Types::Serial
        property :limited,  String,   :set => ['foo', 'bar', 'bang'], :default => 'foo'
      end
    end

    before do
      @boat = LimitedBoat.new
    end

    it 'should set default value' do
      @boat.should be_valid
    end

    it 'should not accept value not in range' do
      @boat.limited = "blah"
      @boat.should_not be_valid
      @boat.errors.on(:limited).should include('Limited must be one of [foo, bar, bang]')
    end

  end

  describe 'for custom messages' do
    it "should have correct error message" do
      custom_boat = Class.new do
        include DataMapper::Resource
        property :id,   DataMapper::Types::Serial
        property :name, String,  :nullable => false, :message => "This boat must have name"
      end
      boat = custom_boat.new
      boat.should_not be_valid
      boat.errors.on(:name).should include('This boat must have name')
    end

    it "should have correct error messages" do
      custom_boat = Class.new do
        include DataMapper::Resource
        property :id,   DataMapper::Types::Serial
        property :name, String,  :nullable => false, :length => 5..20, :format => /^[a-z]+$/,
                 :messages => {
                   :presence => "This boat must have name",
                   :length => "Name must have at least 4 and at most 20 chars",
                   :format => "Please use only small letters"
                 }
      end

      boat = custom_boat.new
      boat.should_not be_valid
      boat.errors.on(:name).should include("This boat must have name")
      boat.errors.on(:name).should include("Name must have at least 4 and at most 20 chars")
      boat.errors.on(:name).should include("Please use only small letters")

      boat.name = "%%"
      boat.should_not be_valid
      boat.errors.on(:name).should_not include("This boat must have name")
      boat.errors.on(:name).should include("Name must have at least 4 and at most 20 chars")
      boat.errors.on(:name).should include("Please use only small letters")

      boat.name = "%%asd"
      boat.should_not be_valid
      boat.errors.on(:name).should_not include("This boat must have name")
      boat.errors.on(:name).should_not include("Name must have at least 4 and at most 20 chars")
      boat.errors.on(:name).should include("Please use only small letters")

      boat.name = "superboat"
      boat.should be_valid
      boat.errors.on(:name).should be_nil
    end
  end
end
