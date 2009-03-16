require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe DataMapper::Validate::UniquenessValidator do
    before do
       DataMapper.repository do
         ::DataMapper::Validate::Fixtures::Organisation.new(:id => 1, :name=>'Org One', :domain=>'taken').save
         ::DataMapper::Validate::Fixtures::Organisation.new(:id => 2, :name=>'Org Two', :domain=>'two').save

         ::DataMapper::Validate::Fixtures::User.new(:organisation_id => 1, :user_name => 'guy').save
      end
    end

    it 'should validate the uniqueness of a value on a resource' do
       DataMapper.repository do
        o = ::DataMapper::Validate::Fixtures::Organisation.get!(1)
        o.should be_valid

        o = ::DataMapper::Validate::Fixtures::Organisation.new(:id=>20, :name=>"Org Twenty", :domain=>nil)
        o.should be_valid
        o.save

        o = ::DataMapper::Validate::Fixtures::Organisation.new(:id=>30, :name=>"Org Thirty", :domain=>nil)
        o.should be_valid
      end
    end

    it "should not even check if :allow_nil is true" do
       DataMapper.repository do
        o = ::DataMapper::Validate::Fixtures::Organisation.get!(1)
        o.should be_valid

        o = ::DataMapper::Validate::Fixtures::Organisation.new(:id=>2, :name=>"Org Two", :domain=>"taken")
        o.should_not be_valid
        o.errors.on(:domain).should include('Domain is already taken')

        o = ::DataMapper::Validate::Fixtures::Organisation.new(:id=>2, :name=>"Org Two", :domain=>"not_taken")
        o.should be_valid
      end
    end

    it 'should validate uniqueness on a string key' do
      hr  = ::DataMapper::Validate::Fixtures::Department.create(:name => "HR")
      hr2 = ::DataMapper::Validate::Fixtures::Department.new(:name => "HR")
      hr2.valid?.should == false
    end

    it 'should validate the uniqueness of a value with scope' do
       DataMapper.repository do
        u = ::DataMapper::Validate::Fixtures::User.new(:id => 2, :organisation_id=>1, :user_name => 'guy')
        u.should_not be_valid_for_testing_property
        u.errors.on(:user_name).should include('User name is already taken')
        u.should_not be_valid_for_testing_association
        u.errors.on(:user_name).should include('User name is already taken')


        u = ::DataMapper::Validate::Fixtures::User.new(:id => 2, :organisation_id => 2, :user_name  => 'guy')
        u.should be_valid_for_testing_property
        u.should be_valid_for_testing_association
      end
    end
  end
end
