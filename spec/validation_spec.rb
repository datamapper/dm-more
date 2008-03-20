require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/validate'


describe DataMapper::Validate, 'acting on a resource' do  
  before(:all) do
    class Yacht
      include DataMapper::Resource
      include DataMapper::Validate
      
      property :name, String   
            
      validates_presence_of :name  
    end    
  end
  
  it "should respond to validatable? (for recursing assocations)" do
    Yacht.new().should be_validatable
    Class.new.new.should_not be_validatable
  end

  it "should have a set of errors on the instance of the resource" do
    shamrock = Yacht.new
    shamrock.respond_to?(:errors).should == true
  end
  
  it "should have a set of contextual validations on the class of the resource" do
    Yacht.respond_to?(:validators).should == true
  end
  
  it "should execute all validators for a given context against the resource" do
    Yacht.validators.respond_to?(:execute).should == true        
  end
  
  it "should place a validator in the :default context if a named context is not provided" do
    # from validates_presence_of :name 
    Yacht.validators.context(:default).length.should == 1  
  end

  
  it "should allow multiple user defined contexts for a validator" do
    class Yacht
      property :port, String   
      validates_presence_of :port, :context => [:at_sea, :in_harbor]     
    end
    Yacht.validators.context(:at_sea).length.should == 1
    Yacht.validators.context(:in_harbor).length.should == 1
    Yacht.validators.context(:no_such_context).length.should == 0
  end
  
  it "should alias :on and :when for :context" do
    class Yacht
      property :owner, String
      property :bosun, String
      
      validates_presence_of :owner, :on => :owned_vessel
      validates_presence_of :bosun, :when => [:under_way]    
    end    
    Yacht.validators.context(:owned_vessel).length.should == 1
    Yacht.validators.context(:under_way).length.should == 1
  end
  
  it "should alias :group for :context (backward compat with Validatable??)" do
    class Yacht
      property :captain, String
      validates_presence_of :captain, :group => [:captained_vessel]
    end
    Yacht.validators.context(:captained_vessel).length.should == 1    
  end
  
  it "should add a method valid_for_<context_name>? for each context" do
    class Yacht
      property :engine_size, String
      validates_presence_of :engine_size, :when => :power_boat
    end
    
    cigaret = Yacht.new
    cigaret.valid_for_default?.should_not == true
    cigaret.respond_to?(:valid_for_power_boat?).should == true
    cigaret.valid_for_power_boat?.should_not == true
    
    cigaret.engine_size = '4 liter V8'
    cigaret.valid_for_power_boat?.should == true
  end
  
  it "should be able to translate the error message" # needs String::translations
  
  it "should be able to get the error message for a given field" do
    class Yacht
      property :wood_type, String      
      validates_presence_of :wood_type, :on => :wooden_boats
    end    
    fantasy = Yacht.new
    fantasy.valid_for_wooden_boats?.should == false
    fantasy.errors.on(:wood_type).first.should == 'Wood type must not be blank'
    fantasy.wood_type = 'birch'
    fantasy.valid_for_wooden_boats?.should == true
  end
  
  it "should be able to specify a custom error message" do
    class Yacht
      property :year_built, String
      validates_presence_of :year_built, :when => :built, :message => 'Year built is a must enter field'
    end
    
    sea = Yacht.new
    sea.valid_for_built?.should == false
    sea.errors.full_messages.first.should == 'Year built is a must enter field'
  end

  it "should execute a Proc when provided in an :if clause and run validation if the Proc returns true" do
    class Dingy
      include DataMapper::Resource
      include DataMapper::Validate
          
      property :owner, String
      validates_presence_of :owner, :if => Proc.new{|resource| resource.owned?()}      
      def owned?; false; end
    end
    
    Dingy.new().valid?.should == true
    
    class Dingy
      def owned?; true; end
    end
      
    Dingy.new().valid?.should_not == true
  end
  
  it "should execute a symbol or method name provided in an :if clause and run validation if the method returns true" do
    class Dingy
      validators.clear!
      validates_presence_of :owner, :if => :owned?      
      
      def owned?; false; end      
    end
    
    Dingy.new().valid?.should == true
    
    class Dingy
      def owned?; true; end
    end
    
    Dingy.new().valid?.should_not == true    
  end
  
   
  
  it "should execute a Proc when provided in an :unless clause and not run validation if the Proc returns true" do
    class RowBoat
      include DataMapper::Resource
      include DataMapper::Validate
      validates_presence_of :salesman, :unless => Proc.new{|resource| resource.sold?()}     
      
      def sold?; false; end      
    end    
    
    RowBoat.new().valid?.should_not == true
    
    class RowBoat
      def sold?; true; end
    end  
    
    RowBoat.new.valid?().should == true
  end

  it "should execute a symbol or method name provided in an :unless clause and not run validation if the method returns true" do
    class Dingy
      validators.clear!
      validates_presence_of :salesman, :unless => :sold?      
      
      def sold?; false; end      
    end    
    
    Dingy.new().valid?.should_not == true  #not sold and no salesman
    
    class Dingy
      def sold?; true; end
    end  
    
    Dingy.new().valid?.should == true    # sold and no salesman
  end
end

#-----------------------------------------------------------------------------

describe DataMapper::Validate::RequiredFieldValidator, 'on a resource field' do
  before(:all) do
    class Boat
      include DataMapper::Resource
      include DataMapper::Validate
      
      property :name, String   
            
      validates_presence_of :name    
    end
  end

  it "should validate the presence of a value on an instance of a resource" do
    sting_ray = Boat.new
    sting_ray.valid?.should_not == true
    sting_ray.errors.full_messages.include?('Name must not be blank').should == true
    
    sting_ray.name = 'Sting Ray'
    sting_ray.valid?.should == true
    sting_ray.errors.full_messages.length.should == 0  
  end
  
end


#-----------------------------------------------------------------------------

describe DataMapper::Validate::AbsentFieldValidator, 'on a resource field' do
  before(:all) do
    class Kayak
      include DataMapper::Resource
      include DataMapper::Validate
      
      property :salesman, String   
            
      validates_absence_of :salesman, :when => :sold    
    end
  end

  it "should validate the absense of a value on an instance of a resource (absense = nil || '')" do
    kayak = Kayak.new
    kayak.valid_for_sold?.should == true
    
    kayak.salesman = 'Joe'
    kayak.valid_for_sold?.should_not == true    
  end
  
end

#-------------------------------------------------------------------------------
describe DataMapper::Validate::ConfirmationValidator, 'on a resource field' do
  before(:all) do
    class Canoe
      include DataMapper::Validate
      
      def name=(value)
        @name = value
      end
      
      def name
        @name ||= nil
      end
      
      def name_confirmation=(value)
        @name_confirmation = value
      end
      
      def name_confirmation
        @name_confirmation ||= nil
      end
      
      validates_confirmation_of :name
    end
  end
  
  it "should validate the confrimation of a value on an instance of a resource" do
    canoe = Canoe.new
    canoe.name = 'White Water'
    canoe.name_confirmation = 'Not confirmed'
    canoe.valid?.should_not == true    
    canoe.errors.full_messages.first.should == 'Name does not match the confirmation'
    
    canoe.name_confirmation = 'White Water'
    canoe.valid?.should == true
  end
  
  it "should default the name of the confirimation field to <field>_confirmation if one is not specified" do
    canoe = Canoe.new
    canoe.name = 'White Water'
    canoe.name_confirmation = 'White Water'
    canoe.valid?.should == true    
  end
  
  it "should default to allowing nil values on the fields if not specified to" do
    Canoe.new().valid?().should == true
  end
  
  it "should not pass validation with a nil value when specified to" do
    class Canoe
      validators.clear!
      validates_confirmation_of :name, :allow_nil => false
    end
    Canoe.new().valid?().should_not == true
  end
  
  it "should allow the name of the confrimation field to be set" do
    class Canoe
      validators.clear!
      validates_confirmation_of :name, :confirm => :name_check
      def name_check=(value)
        @name_check = value
      end
      
      def name_check
        @name_confirmation ||= nil
      end    
    end
    canoe = Canoe.new
    canoe.name = 'Float'
    canoe.name_check = 'Float'
    canoe.valid?.should == true
    
  end
  
end


#-------------------------------------------------------------------------------
describe DataMapper::Validate::FormatValidator, 'on a resource field' do
  before(:all) do
    class BillOfLading
      include DataMapper::Resource    
      include DataMapper::Validate
      
      property :doc_no, String

      # this is a trivial example
      validates_format_of :doc_no, :with => lambda { |code|
        (code =~ /A\d{4}/) || (code =~ /[B-Z]\d{6}X12/)
      }    
    end
  end
  
  it "should validate the format of a value on an instance of a resource" do
    bol = BillOfLading.new
    bol.doc_no = 'BAD CODE :)'
    bol.valid?.should == false
    bol.errors.full_messages.first.should == 'Doc no is invalid'
    
    bol.doc_no = 'A1234'
    bol.valid?.should == true
    
    bol.doc_no = 'B123456X12'
    bol.valid?.should == true
  end
  
  it "should have pre-defined formats"  
end



#-------------------------------------------------------------------------------
describe DataMapper::Validate::LengthValidator, 'on a resource field' do
  before(:all) do
    class MotorLaunch
      include DataMapper::Resource    
      include DataMapper::Validate      
      property :name, String
    end
  end

  it "should be able to set a minimum length of a string field" do
    class MotorLaunch
      validates_length_of :name, :min => 3
    end
    launch = MotorLaunch.new
    launch.name = 'Ab'
    launch.valid?.should == false
    launch.errors.full_messages.first.should == 'Name must be more than 3 characters long'
  end
  
  it "should be able to alias :minimum for :min " do
    class MotorLaunch
      validators.clear!
      validates_length_of :name, :minimum => 3
    end
    launch = MotorLaunch.new
    launch.name = 'Ab'
    launch.valid?.should == false
    launch.errors.full_messages.first.should == 'Name must be more than 3 characters long'
  end
  
  it "should be able to set a maximum length of a string field" do
    class MotorLaunch
      validators.clear!
      validates_length_of :name, :max => 5
    end
    launch = MotorLaunch.new
    launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
    launch.valid?.should == false
    launch.errors.full_messages.first.should == 'Name must be less than 5 characters long'        
  end
  
  it "should be able to alias :maximum for :max" do 
    class MotorLaunch
      validators.clear!
      validates_length_of :name, :maximum => 5
    end
    launch = MotorLaunch.new
    launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
    launch.valid?.should == false
    launch.errors.full_messages.first.should == 'Name must be less than 5 characters long'   
  end
  
  it "should be able to specify a length range of a string field" do
    class MotorLaunch
      validators.clear!
      validates_length_of :name, :in => (3..5)  
    end
    launch = MotorLaunch.new
    launch.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
    launch.valid?.should == false
    launch.errors.full_messages.first.should == 'Name must be between 3 and 5 characters long'      
    
    launch.name = 'A'
    launch.valid?.should == false
    launch.errors.full_messages.first.should == 'Name must be between 3 and 5 characters long'      

    launch.name = 'Ride'
    launch.valid?.should == true    
  end
  
  it "should be able to alias :within for :in" do
    class MotorLaunch
      validators.clear!
      validates_length_of :name, :within => (3..5)  
    end
    launch = MotorLaunch.new
    launch.name = 'Ride'
    launch.valid?.should == true      
  end  
end


#-------------------------------------------------------------------------------
describe DataMapper::Validate::WithinValidator, 'on a resource field' do
  before(:all) do
    class Telephone
      include DataMapper::Resource    
      include DataMapper::Validate
      
      property :type_of_number, String
      validates_within :type_of_number, :set => ['Home','Work','Cell']   
    end
  end
  
  it "should validate a value on an instance of a resource within a predefined set of values" do
    tel = Telephone.new
    tel.valid?.should_not == true
    tel.errors.full_messages.first.should == 'Type of number must be one of [Home, Work, Cell]'
    
    tel.type_of_number = 'Cell'
    tel.valid?.should == true
  end
end  


#-------------------------------------------------------------------------------
describe DataMapper::Validate::NumericValidator, 'on a resource field' do
  before(:all) do
    class Bill
      include DataMapper::Resource    
      include DataMapper::Validate
      
      property :amount_1, String
      property :amount_2, Float

      
      validates_numericalnes_of :amount_1, :amount_2      
    end
  end
  
  it "should validate a floating point value on the instance of a resource" do
    b = Bill.new
    b.valid?.should_not == true
    b.amount_1 = 'ABC'
    b.amount_2 = 27.343
    b.valid?.should_not == true
    b.amount_1 = '34.33'
    b.valid?.should == true    
  end
  
  it "should validate an integer value on the instance of a resource" do
    class Bill
      property :quantity_1, String
      property :quantity_2, Fixnum    
    
      validators.clear!
      validates_numericalnes_of :quantity_1, :quantity_2, :integer_only => true
    end
    b = Bill.new
    b.valid?.should_not == true
    b.quantity_1 = '12.334'
    b.quantity_2 = 27.343
    b.valid?.should_not == true
    b.quantity_1 = '34.33'
    b.quantity_2 = 22
    b.valid?.should_not == true    
    b.quantity_1 = '34'
    b.valid?.should == true    
    
  end
  
end  


