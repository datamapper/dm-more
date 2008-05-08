require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

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

