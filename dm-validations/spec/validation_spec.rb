require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-validations'

begin

  require 'do_sqlite3'

  DB_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/integration_test.db'
  FileUtils.touch DB_PATH
  
  LOG_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/sql.log'
  FileUtils.touch LOG_PATH
  DataMapper::Logger.new(LOG_PATH, 0)
  at_exit { DataMapper.logger.close }
  
  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")
  

  describe DataMapper::Validate do  
    before(:all) do
      class Yacht
        include DataMapper::Resource
        include DataMapper::Validate
        property :name, String, :auto_validation => false   
                    
        validates_presence_of :name  
      end    
    end
    
    it "should respond to validatable? (for recursing assocations)" do
      Yacht.new().should be_validatable
      Class.new.new.should_not be_validatable
    end

    it "should have a set of errors on the instance of the resource" do
      shamrock = Yacht.new
      shamrock.should respond_to(:errors)
    end
    
    it "should have a set of contextual validations on the class of the resource" do
      Yacht.should respond_to(:validators)
    end
    
    it "should execute all validators for a given context against the resource" do
      Yacht.validators.should respond_to(:execute)
    end
    
    it "should place a validator in the :default context if a named context is not provided" do
      # from validates_presence_of :name 
      Yacht.validators.context(:default).length.should == 1  
    end

    
    it "should allow multiple user defined contexts for a validator" do
      class Yacht
        property :port, String, :auto_validation => false      
        validates_presence_of :port, :context => [:at_sea, :in_harbor]     
      end
      Yacht.validators.context(:at_sea).length.should == 1
      Yacht.validators.context(:in_harbor).length.should == 1
      Yacht.validators.context(:no_such_context).length.should == 0
    end
    
    it "should alias :on and :when for :context" do
      class Yacht
        property :owner, String, :auto_validation => false   
        property :bosun, String, :auto_validation => false   
        
        validates_presence_of :owner, :on => :owned_vessel
        validates_presence_of :bosun, :when => [:under_way]    
      end    
      Yacht.validators.context(:owned_vessel).length.should == 1
      Yacht.validators.context(:under_way).length.should == 1
    end
    
    it "should alias :group for :context (backward compat with Validatable??)" do
      class Yacht
        property :captain, String, :auto_validation => false   
        validates_presence_of :captain, :group => [:captained_vessel]
      end
      Yacht.validators.context(:captained_vessel).length.should == 1    
    end
    
    it "should add a method valid_for_<context_name>? for each context" do
      class Yacht
        property :engine_size, String, :auto_validation => false   
        validates_presence_of :engine_size, :when => :power_boat
      end
      
      cigaret = Yacht.new
      cigaret.valid_for_default?.should_not == true
      cigaret.should respond_to(:valid_for_power_boat?)
      cigaret.valid_for_power_boat?.should_not == true
      
      cigaret.engine_size = '4 liter V8'
      cigaret.valid_for_power_boat?.should == true
    end
    
    it "should add a method all_valid_for_<context_name>? for each context" do
      class Yacht
        property :mast_height, String, :auto_validation => false   
        validates_presence_of :mast_height, :when => :sailing_vessel
      end    
      swift = Yacht.new
      swift.should respond_to(:all_valid_for_sailing_vessel?)
    end
    
    it "should be able to translate the error message" # needs String::translations
    
    it "should be able to get the error message for a given field" do
      class Yacht
        property :wood_type, String, :auto_validation => false        
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
        property :year_built, String, :auto_validation => false   
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
        property :owner, String, :auto_validation => false   
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
    
    
    it "should perform automatic recursive validation #all_valid? checking all instance variables (and ivar.each items if valid)" do
    
      class Invoice
        include DataMapper::Resource
        include DataMapper::Validate
        property :customer, String, :auto_validation => false     
        validates_presence_of :customer
        
        def line_items
          @line_items || @line_items = []
        end
        
        def comment
          @comment || nil
        end
        
        def comment=(value)
          @comment = value
        end                
      end
      
      class LineItem
        include DataMapper::Resource
        include DataMapper::Validate   
        property :price, String, :auto_validation => false   
        validates_numericalnes_of :price
        
        def initialize(price)
          @price = price
        end
      end
      
      class Comment
        include DataMapper::Resource
        include DataMapper::Validate    
        property :note, String, :auto_validation => false   
        
        validates_presence_of :note
      end
    
      invoice = Invoice.new(:customer => 'Billy Bob')    
      invoice.valid?.should == true
          
      for i in 1..6 do 
        invoice.line_items << LineItem.new(i.to_s)
      end    
      invoice.line_items[1].price = 'BAD VALUE'  
      invoice.comment = Comment.new
          
      invoice.comment.valid?.should == false
      invoice.line_items[1].valid?.should == false
      
      invoice.all_valid?.should == false
      invoice.comment.note = 'This is a note'
      
      invoice.all_valid?.should == false
      invoice.line_items[1].price = '23.44'
      
      invoice.all_valid?.should == true
    
    end 
    
    #-------------------------------------------------------------------------------  
    describe "Automatic Validation from Property Definition" do
      before(:all) do
        class SailBoat
          include DataMapper::Resource
          include DataMapper::Validate        
          property :name, String, :nullable => false , :validates => :presence_test    
          property :description, String, :length => 10, :validates => :length_test_1
          property :notes, String, :length => 2..10, :validates => :length_test_2
          property :no_validation, String, :auto_validation => false
          property :salesman, String, :nullable => false, :validates => [:multi_context_1, :multi_context_2]
          property :code, String, :format => Proc.new { |code| code =~ /A\d{4}/}, :validates => :format_test
          property :allow_nil, String, :size => 5..10, :nullable => true, :validates => :nil_test
        end
      end
    
      it "should have a hook for adding auto validations called from DataMapper::Property#new" do
        SailBoat.should respond_to(:auto_generate_validations)
      end    
      
      it "should auto add a validates_presence_of when property has option :nullable => false" do
        validator = SailBoat.validators.context(:presence_test).first
        validator.is_a?(DataMapper::Validate::RequiredFieldValidator).should == true
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
        boat.valid_for_length_test_2?.should == false 
        boat.notes = 'AB' #2
        boat.valid_for_length_test_2?.should == true 
        boat.notes = 'ABCDEFGHIJK' #11
        boat.valid_for_length_test_2?.should == false 
        boat.notes = 'ABCDEFGHIJ' #10      
        boat.valid_for_length_test_2?.should == true      
      end
      
      it "should auto add a validates_format_of if the :format option is given" do
        # format test - format = /A\d{4}/   on code
        boat = SailBoat.new
        boat.valid_for_format_test?.should == false
        boat.code = 'A1234'
        boat.valid_for_format_test?.should == true
        boat.code = 'BAD CODE'
        boat.valid_for_format_test?.should == false      
      end
      
      it "should auto validate all strings for max length" do
        class Test
          include DataMapper::Resource
          include DataMapper::Validate        
          property :name, String
        end
        Test.new().valid?().should == true
        t = Test.new()
        t.name = 'Lip­smackin­thirst­quenchin­acetastin­motivatin­good­buzzin­cool­talkin­high­walkin­fast­livin­ever­givin­cool­fizzin'
        t.valid?().should == false
        t.errors.full_messages.should include('Name must be less than 50 characters long')
      end
      
      it "should not auto add any validators if the option :auto_validation => false was given" do
        class Test
          include DataMapper::Resource
          include DataMapper::Validate        
          property :name, String, :nullable => false, :auto_validation => false
        end
        Test.new().valid?().should == true
      end
      
      it 'It should auto add range checking the length of a string while still allowing null values' do
        boat = SailBoat.new()
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
          
    end
  end

  #-----------------------------------------------------------------------------

  describe DataMapper::Validate::RequiredFieldValidator do
    after do
      repository(:sqlite3).adapter.execute('DROP TABLE "landscapers"');
      repository(:sqlite3).adapter.execute('DROP TABLE "gardens"');
    end
    
    before do
      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        CREATE TABLE "landscapers" (
          "id" INTEGER PRIMARY KEY,
          "name" VARCHAR(50)
        )
      EOS
      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        CREATE TABLE "gardens" (
          "id" INTEGER PRIMARY KEY,
          "landscaper_id" INTEGER,
          "name" VARCHAR(50)
        )
      EOS
      
      class Landscaper
        include DataMapper::Resource
        include DataMapper::Validate
        property :id, Fixnum, :key => true
        property :name, String        
      end
      
      class Garden
        include DataMapper::Resource
        include DataMapper::Validate
        property :id, Fixnum, :key => true
        property :landscaper_id, Fixnum
        property :name, String, :auto_validation => false                  
        
        has :landscaper, 1..n
        
        validates_presence_of :name, :when => :property_test    
        validates_presence_of :landscaper, :when => :association_test    
      end
    end

    it "should validate the presence of a property value on an instance of a resource" do
      garden = Garden.new
      garden.should_not be_valid_for_property_test
      garden.errors.on(:name).should include('Name must not be blank')
      
      garden.name = 'The Wilds'
      garden.should be_valid_for_property_test
    end
    
    it "should validate the presence of an association value on an instance of a resource" 
    #do
    #  garden = Garden.new
    #  landscaper = garden.landscaper
    #  puts landscaper.children.length
    #  #puts "Gardens landscaper is #{garden.landscaper.child_key}"
    #end
    
  end


  #-----------------------------------------------------------------------------
  describe DataMapper::Validate::AbsentFieldValidator do
    before(:all) do
      class Kayak
        include DataMapper::Resource
        include DataMapper::Validate
        property :salesman, String, :auto_validation => false      
              
        validates_absence_of :salesman, :when => :sold    
      end
    end

    it "should validate the absense of a value on an instance of a resource" do
      kayak = Kayak.new
      kayak.valid_for_sold?.should == true
      
      kayak.salesman = 'Joe'
      kayak.valid_for_sold?.should_not == true    
    end
    
  end

  #-------------------------------------------------------------------------------
  describe DataMapper::Validate::ConfirmationValidator do
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
  describe DataMapper::Validate::FormatValidator do
    before(:all) do
      class BillOfLading
        include DataMapper::Resource    
        include DataMapper::Validate
        property :doc_no, String, :auto_validation => false   

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
  describe DataMapper::Validate::LengthValidator do
    before(:all) do
      class MotorLaunch
        include DataMapper::Resource    
        include DataMapper::Validate     
        property :name, String, :auto_validation => false   
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
  describe DataMapper::Validate::WithinValidator do
    before(:all) do
      class Telephone
        include DataMapper::Resource    
        include DataMapper::Validate
        property :type_of_number, String, :auto_validation => false   
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
  describe DataMapper::Validate::MethodValidator do
    before(:all) do
      class Ship
        include DataMapper::Resource    
        include DataMapper::Validate
        property :name, String
        
        validates_with_method :fail_validation, :when => [:testing_failure]
        validates_with_method :pass_validation, :when => [:testing_success]
        
        def fail_validation
          return false, 'Validation failed'
        end
        
        def pass_validation
          return true
        end    
      end
    end
    
    it "should validate via a method on the resource" do
      Ship.new().valid_for_testing_failure?().should == false
      Ship.new().valid_for_testing_success?().should == true
      ship = Ship.new()
      ship.valid_for_testing_failure?().should == false
      ship.errors.full_messages.include?('Validation failed').should == true
    end
    
  end

  #-------------------------------------------------------------------------------
  describe DataMapper::Validate::NumericValidator do
    before(:all) do
      class Bill
        include DataMapper::Resource    
        include DataMapper::Validate
        property :amount_1, String, :auto_validation => false   
        property :amount_2, Float, :auto_validation => false   

        
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
        property :quantity_1, String, :auto_validation => false   
        property :quantity_2, Fixnum, :auto_validation => false      
      
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



  describe DataMapper::Validate::UniquenessValidator do
    after do
      repository(:sqlite3).adapter.execute('DROP TABLE "organisations"');
      repository(:sqlite3).adapter.execute('DROP TABLE "users"');
    end
    
    before do
      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        CREATE TABLE "organisations" (
          "id" INTEGER PRIMARY KEY,
          "name" VARCHAR(50),
          "domain" VARCHAR(50)
        )
      EOS
      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        CREATE TABLE "users" (
          "id" INTEGER PRIMARY KEY,
          "organisation_id" INTEGER,
          "user_name" VARCHAR(50)
        )
      EOS
          
      class Organisation
        include DataMapper::Resource    
        include DataMapper::Validate
        property :id, Fixnum, :key => true
        property :name, String
        property :domain, String #, :unique => true      
        
        validates_uniqueness_of :domain
      end
      
      class User 
        include DataMapper::Resource    
        include DataMapper::Validate
        property :id, Fixnum, :key => true
        property :organisation_id, Fixnum
        property :user_name, String
        
        has :organisation, n..1
        
        validates_uniqueness_of :user_name, :when => :testing_association, :scope => [:organisation]
        validates_uniqueness_of :user_name, :when => :testing_property, :scope => [:organisation_id]
        
      end

      repository(:sqlite3) do
         Organisation.new(:id=>1, :name=>'Org One', :domain=>'taken').save    
         Organisation.new(:id=>2, :name=>'Org Two', :domain=>'two').save    
         
         User.new(:id=>1,:organisation_id=>1,:user_name=>'guy').save
      end      
    end
    
    
    it 'should validate the uniqueness of a value on a resource' do
      repository(:sqlite3) do
        o = Organisation[1]
        o.should be_valid
      
        o = Organisation.new(:id=>2,:name=>"Org Two", :domain=>"taken")        
        o.should_not be_valid
        o.errors.on(:domain).should include('Domain is already taken.')
        
        o = Organisation.new(:id=>2,:name=>"Org Two", :domain=>"not_taken") 
        o.should be_valid
      end
    end
    
    it 'should validate the uniqueness of a value with scope' do
      repository(:sqlite3) do        
        u = User.new(:id => 2, :organisation_id=>1, :user_name => 'guy')
        u.should_not be_valid_for_testing_property       
        u.should_not be_valid_for_testing_association 
        
        
        u = User.new(:id => 2, :organisation_id => 2, :user_name  => 'guy')
        u.should be_valid_for_testing_property
        u.should be_valid_for_testing_association
      end      
    end
    
    
  end


rescue LoadError
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end


 
