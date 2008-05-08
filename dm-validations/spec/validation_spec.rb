require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

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
    
  end


rescue LoadError
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{$!}"
    end
  end
end
