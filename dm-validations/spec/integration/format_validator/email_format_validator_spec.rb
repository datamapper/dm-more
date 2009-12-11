require 'spec_helper'
require 'integration/format_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::BillOfLading' do
  before :all do
    DataMapper::Validate::Fixtures::BillOfLading.auto_migrate!
  end

  def valid_attributes
    { :id => 1, :doc_no => 'A1234', :email => 'user@example.com', :url => 'http://example.com' }
  end

  @valid_email_addresses = [
        '+1~1+@example.com',
        '{_dave_}@example.com',
        '"[[ dave ]]"@example.com',
        'dave."dave"@example.com',
        'test@localhost',
        'test@example.com',
        'test@example.co.uk',
        'test@example.com.br',
        '"J. P. \'s-Gravezande, a.k.a. The Hacker!"@example.com',
        'me@[187.223.45.119]',
        'someone@123.com',
        'simon&garfunkel@songs.com'].each do |email|

    describe "with email value of #{email} (RFC2822 compliant)" do
      before :all do
        @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:email => email))
      end

      it_should_behave_like "valid model"
    end
  end


  @invalid_email_addresses = [
        '-- dave --@example.com',
        '[dave]@example.com',
        '.dave@example.com',
        'Max@Job 3:14',
        'Job@Book of Job',
        'J. P. \'s-Gravezande, a.k.a. The Hacker!@example.com'].each do |email|
    describe "with email value of #{email} (non RFC2822 compliant)" do
      before :all do
        @model = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.merge(:email => email))
      end

      it_should_behave_like "invalid model"
    end
  end


  it 'should have a pre-defined URL format' do
    bad = [ 'http:// example.com',
            'ftp://example.com',
            'http://.com',
            'http://',
            'test',
            '...'
          ]

    good = [
            'http://example.com',
            'http://www.example.com',
           ]

    bol = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes.except(:url))
    bol.should_not be_valid
    bol.errors.on(:url).should == [ 'Url has an invalid format' ]

    bad.map do |e|
      bol.url = e
      bol.valid?
      bol.errors.on(:url).should == [ 'Url has an invalid format' ]
    end

    good.map do |e|
      bol.url = e
      bol.valid?
      bol.errors.on(:url).should be_nil
    end

  end

  describe 'with a regexp' do
    before do
      @bol = DataMapper::Validate::Fixtures::BillOfLading.new(valid_attributes)
      @bol.should be_valid
    end

    describe 'if matched' do
      before do
        @bol.username = 'a12345'
      end

      it 'should validate' do
        @bol.should be_valid
      end
    end

    describe 'if not matched' do
      before do
        @bol.username = '12345'
      end

      it 'should not validate' do
        @bol.should_not be_valid
      end

      it 'should set an error message' do
        @bol.valid?
        @bol.errors.on(:username).should == [ 'Username must have at least one letter' ]
      end
    end
  end
end
