require 'spec_helper'

class Story
  include DataMapper::Resource

  property :id,         Serial
  property :title,      String
  property :updated_at, DateTime
  property :type,       Discriminator

  before :save do
    # For the sake of testing, make sure the updated_at is always unique
    if dirty?
      time = self.updated_at ? self.updated_at + 1 : Time.now
      self.updated_at = time
    end
  end

  is_versioned :on => :updated_at
end

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::Versioned' do
    describe 'inner class' do
      it 'should be present' do
        Story::Version.should be_a_kind_of(DataMapper::Model)
      end

      it 'should have a default storage name' do
        Story::Version.storage_name.should == 'story_versions'
      end

      Story.properties.each do |property|
        it "should have its parent's property #{property.name}" do
          Story::Version.properties.should include(property)
        end
      end
    end

    describe '#create' do
      before :all do
        Story.auto_migrate!
        Story.create(:title => 'A Very Interesting Article')
      end

      it 'should not create a versioned copy' do
        Story::Version.all.size.should == 0
      end
    end

    describe '#save' do
      before :all do
        Story.auto_migrate!
      end

      describe '(with new resource)' do
        before :all do
          @story = Story.new(:title => 'A Story')
          @story.save
        end

        it 'should not create a versioned copy' do
          Story::Version.all.size.should == 0
        end
      end

      describe '(with a clean existing resource)' do
        before :all do
          @story = Story.create(:title => 'A Story')
          @story.save
        end

        it 'should not create a versioned copy' do
          Story::Version.all.size.should == 0
        end
      end

      describe '(with a dirty existing resource)' do
        before :all do
          @story = Story.create(:title => 'A Story')
          @story.title = 'An Inner Update'
          @story.title = 'An Updated Story'
          @story.save
        end

        it 'should create a versioned copy' do
          Story::Version.all.size.should == 1
        end

        it 'should not have the same value for the versioned field' do
          @story.updated_at.should_not == Story::Version.first.updated_at
        end

        it 'should save the original value, not the inner update' do
          # changes to the story between saves shouldn't be updated.
          @story.versions.last.title.should == 'A Story'
        end
      end
    end

    describe '#versions' do
      before :all do
        Story.auto_migrate!
        @story = Story.create(:title => 'A Story')
      end

      it 'should return an empty array when there are no versions' do
        @story.versions.should == []
      end

      it 'should return a collection when there are versions' do
        @story.versions.should == Story::Version.all(:id => @story.id)
      end

      it "should not return another object's versions" do
        @story2 = Story.create(:title => 'A Different Story')
        @story2.title = 'A Different Title'
        @story2.save
        @story.versions.should == Story::Version.all(:id => @story.id)
      end
    end
  end
end
