require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  class SailBoat
    include DataMapper::Resource
    include DataMapper::Validate
    property :id,            Fixnum,     :key => true
    property :name,          String,                                :nullable => false,     :validates       => :presence_test
    property :description,   String,     :length => 10,                                     :validates       => :length_test_1
    property :notes,         String,     :length => 2..10,                                  :validates       => :length_test_2
    property :no_validation, String,                                                        :auto_validation => false
    property :salesman,      String,                                :nullable => false,     :validates       => [:multi_context_1, :multi_context_2]
    property :code,          String,     :format => Proc.new { |code| code =~ /A\d{4}\z/ }, :validates       => :format_test
    property :allow_nil,     String,     :size => 5..10,            :nullable => true,      :validates       => :nil_test
    property :float,         Float,      :scale => 2, :precision => 1
    property :big_decimal,   BigDecimal, :scale => 2, :precision => 1

    # bypass typecasting so we can set values for specs
    def set(attributes)
      attributes.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end
  end

  describe "Automatic Validation from Property Definition" do
    it "should have a hook for adding auto validations called from DataMapper::Property#new" do
      SailBoat.should respond_to(:auto_generate_validations)
    end

    it "should auto add a validates_presence_of when property has option :nullable => false" do
      validator = SailBoat.validators.context(:presence_test).first
      validator.should be_kind_of(DataMapper::Validate::RequiredFieldValidator)
      validator.field_name.should == :name

      boat = SailBoat.new
      boat.valid_for_presence_test?.should == false
      boat.name = 'Float'
      boat.valid_for_presence_test?.should == true
    end

    it "should auto add a validates_length_of for maximum size on String properties" do
      # max length test max=10
      boat = SailBoat.new
      boat.valid_for_length_test_1?.should == true  #no minimum length
      boat.description = 'ABCDEFGHIJK' #11
      boat.valid_for_length_test_1?.should == false
      boat.description = 'ABCDEFGHIJ' #10
      boat.valid_for_length_test_1?.should == true
    end

    it "should auto add validates_length_of within a range when option :length or :size is a range" do
      # Range test notes = 2..10
      boat = SailBoat.new
      boat.should be_valid_for_length_test_2
      boat.notes = 'AB' #2
      boat.should be_valid_for_length_test_2
      boat.notes = 'ABCDEFGHIJK' #11
      boat.should_not be_valid_for_length_test_2
      boat.notes = 'ABCDEFGHIJ' #10
      boat.should be_valid_for_length_test_2
    end

    it "should auto add a validates_format_of if the :format option is given" do
      # format test - format = /A\d{4}\z/   on code
      boat = SailBoat.new
      boat.should be_valid_for_format_test
      boat.code = 'A1234'
      boat.should be_valid_for_format_test
      boat.code = 'BAD CODE'
      boat.should_not be_valid_for_format_test
    end

    it "should auto validate all strings for max length" do
      klass = Class.new do
        include DataMapper::Resource
        include DataMapper::Validate
        property :id, Fixnum, :serial => true
        property :name, String
      end
      t = klass.new(:id => 1)
      t.should be_valid
      t.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
      t.should_not be_valid
      t.errors.full_messages.should include('Name must be less than 50 characters long')
    end

    it "should not auto add any validators if the option :auto_validation => false was given" do
      klass = Class.new do
        include DataMapper::Resource
        include DataMapper::Validate
        property :id, Fixnum, :serial => true, :auto_validation => false
        property :name, String, :nullable => false, :auto_validation => false
      end
      klass.new.valid?.should == true
    end

    it 'should auto add range checking the length of a string while still allowing null values' do
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

    describe 'for Fixnum properties' do
      before do
        @boat = SailBoat.new
      end

      it 'should allow integers' do
        @boat.set(:id => 1)
        @boat.should be_valid
      end

      it 'should not allow floats' do
        @boat.set(:id => 1.0)
        @boat.should_not be_valid
        @boat.errors.on(:id).should == [ 'Id must be an integer' ]
      end

      it 'should not allow decimals' do
        @boat.set(:id => BigDecimal('1'))
        @boat.should_not be_valid
        @boat.errors.on(:id).should == [ 'Id must be an integer' ]
      end
    end

    { :float => Float, :big_decimal => BigDecimal }.each do |column,type|
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

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
