require 'spec_helper'
require 'integration/required_field_validator/spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe "A plain old Ruby object (not a DM resource)" do
    before do
      class PlainClass
        extend DataMapper::Validate::ClassMethods
        include DataMapper::Validate
        attr_accessor :accessor
        validates_present :here, :empty, :nil, :accessor
        def here;  "here" end
        def empty; ""     end
        def nil;   nil    end
      end

      @pc = PlainClass.new
    end

    it "should fail validation with empty, nil, or blank fields" do
      @pc.should_not be_valid
      @pc.errors.on(:empty).should    == [ 'Empty must not be blank' ]
      @pc.errors.on(:nil).should      == [ 'Nil must not be blank' ]
      @pc.errors.on(:accessor).should == [ 'Accessor must not be blank' ]
    end

    it "giving accessor a value should remove validation error" do
      @pc.accessor = "full"
      @pc.valid?
      @pc.errors.on(:accessor).should be_nil
    end
  end
end
