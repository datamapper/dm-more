require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe "Automatic Validation from Property Definition" do
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
end
