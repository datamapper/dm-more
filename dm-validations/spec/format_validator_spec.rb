require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

  describe DataMapper::Validate::FormatValidator do
    before(:all) do
      class BillOfLading
        include DataMapper::Resource    
        include DataMapper::Validate
        property :doc_no, String, :auto_validation => false   
        property :email, String, :auto_validation => false

        # this is a trivial example
        validates_format_of :doc_no, :with => lambda { |code|
          (code =~ /A\d{4}/) || (code =~ /[B-Z]\d{6}X12/)
        }
        
        validates_format_of :email, :as => :email_address    
      end
    end
    
    it 'should validate the format of a value on an instance of a resource' do
      bol = BillOfLading.new
      bol.doc_no = 'BAD CODE :)'
      bol.should_not be_valid
      bol.errors.on(:doc_no).should include('Doc no has an invalid format')
      
      bol.doc_no = 'A1234'
      bol.valid?
      bol.errors.on(:doc_no).should be_nil
      
      bol.doc_no = 'B123456X12'
      bol.valid?
      bol.errors.on(:doc_no).should be_nil
    end
    
    it 'should have a pre-defined e-mail format' do
      bad = [ '-- guy --@example.com',    # spaces are invalid unless quoted
              '[guy]@example.com',        # square brackets are invalid unless quoted
              '.guy@example.com',         # local part cannot start with .
              'guy@example 10:10',
              'guy@ example dot com',
              'guy'
            ]
            
      good = [
              '+1~1+@example.com',
              '{_guy_}@example.com',
              '"[[ guy ]]"@example.com',
              'guy."guy"@example.com',
              'guy@localhost',
              'guy@example.com', 
              'guy@example.co.uk',
              'guy@example.co.za',
              'guy@[187.223.45.119]',
              'guy@123.com'           
             ]
      
      bol = BillOfLading.new
      bol.should_not be_valid
      bol.errors.on(:email).should include('Email has an invalid format')
      
      bad.map do |e|
        bol.email = e
        bol.valid?
        bol.errors.on(:email).should include('Email has an invalid format')
      end
      
      good.map do |e|
        bol.email = e
        bol.valid?
        bol.errors.on(:email).should be_nil
      end      
      
    end 
    
    it 'should have pre-defined formats'  
  end





=begin
addresses = [
  '-- dave --@example.com', # (spaces are invalid unless enclosed in quotation marks)
  '[dave]@example.com', # (square brackets are invalid, unless contained within quotation marks)
  '.dave@example.com', # (the local part of a domain name cannot start with a period)
  'Max@Job 3:14', 
  'Job@Book of Job',
  'J. P. \'s-Gravezande, a.k.a. The Hacker!@example.com',
  ]
addresses.each do |address|
  if address =~ RFC2822::EmailAddress
    puts "#{address} deveria ter sido rejeitado, ERRO"
  else
    puts "#{address} rejeitado, OK"
  end
end


addresses = [
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
  'simon&garfunkel@songs.com'
  ]
addresses.each do |address|
  if address =~ RFC2822::EmailAddress
    puts "#{address} aceito, OK"
  else
    puts "#{address} deveria ser aceito, ERRO"
  end
end
=end
