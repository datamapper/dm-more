require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

if HAS_SQLITE3
  describe DataMapper::Validate::UniquenessValidator do

    before do
      class Organisation
        include DataMapper::Resource
        property :id, Fixnum, :key => true
        property :name, String
        property :domain, String #, :unique => true

        validates_is_unique :domain
      end

      class User
        include DataMapper::Resource
        property :id, Fixnum, :key => true
        property :organisation_id, Fixnum
        property :user_name, String

        belongs_to :organisation #has :organisation, n..1

        validates_is_unique :user_name, :when => :testing_association, :scope => [:organisation]
        validates_is_unique :user_name, :when => :testing_property, :scope => [:organisation_id]
      end

      Organisation.auto_migrate!(:sqlite3)
      User.auto_migrate!(:sqlite3)

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
        o.errors.on(:domain).should include('Domain is already taken')

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
end
