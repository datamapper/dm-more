require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe "DataMapper::Resource" do
    after do
     DataMapper.repository(:default).adapter.execute('DELETE from green_smoothies');
    end

    before(:all) do
      class ::GreenSmoothie
        include DataMapper::Resource
        property :id, Serial
        property :name, String

        auto_migrate!(:default)
      end
    end

    it "should find/create using find_or_create" do
      DataMapper.repository(:default) do
        green_smoothie = GreenSmoothie.new(:name => 'Banana')
        green_smoothie.save
        GreenSmoothie.find_or_create({:name => 'Banana'}).id.should eql(green_smoothie.id)
        GreenSmoothie.find_or_create({:name => 'Strawberry'}).id.should eql(2)
      end
    end

    it "should use find_by and use the name attribute to find a record" do
      DataMapper.repository(:default) do
        green_smoothie = GreenSmoothie.create({:name => 'Banana'})
        green_smoothie.should == GreenSmoothie.find_by_name('Banana')
      end
    end

    it "should use find_all_by to find records using an attribute" do
      DataMapper.repository(:default) do
        green_smoothie = GreenSmoothie.create({:name => 'Banana'})
        green_smoothie2 = GreenSmoothie.create({:name => 'Banana'})
        found_records = GreenSmoothie.find_all_by_name('Banana')
        found_records.length.should == 2
        found_records.each do |found_record|
          [green_smoothie, green_smoothie2].include?(found_record).should be_true
        end
      end
    end

    ###

    describe '#find_by_sql' do
      before(:each) do
        DataMapper.repository(:default) do
          @resource = GreenSmoothie.create({:name => 'Banana'})
        end
      end

      it 'should find the resource when given a string' do
        DataMapper.repository(:default) do
          found = GreenSmoothie.find_by_sql <<-SQL
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          found.should_not be_empty
          found.first.should == @resource
        end
      end

      it 'should find the resource when given an array containing SQL and bind values' do
        DataMapper.repository(:default) do
          found = GreenSmoothie.find_by_sql [<<-SQL, @resource.id]
            SELECT id, name FROM green_smoothies WHERE id = ?
          SQL

          found.should_not be_empty
          found.first.should == @resource
        end
      end

      it 'should return an empty collection when nothing is found' do
        DataMapper.repository(:default) do
          found = GreenSmoothie.find_by_sql [<<-SQL, 0]
            SELECT id, name FROM green_smoothies WHERE id = ?
          SQL

          found.should be_kind_of(DataMapper::Collection)
          found.should be_empty
        end
      end

      it 'should raise an error if no SQL string or Query is given' do
        DataMapper.repository(:default) do
          lambda { GreenSmoothie.find_by_sql nil }.should raise_error(ArgumentError, /requires a query/)
        end
      end

      it 'should raise an error if an unacceptable argument is given' do
        DataMapper.repository(:default) do
          lambda { GreenSmoothie.find_by_sql :go }.should raise_error(ArgumentError)
        end
      end

      it 'should accept a Query instance' do
        query = GreenSmoothie.find_by_sql([<<-SQL, @resource.id]).query
          SELECT id, name FROM green_smoothies WHERE id = ?
        SQL

        found = GreenSmoothie.find_by_sql(query)
        found.should_not be_empty
        found.first.should == @resource
      end

      # Options.

      describe ':repository option' do
        it 'should use repository identified by the given symbol' do
          found = GreenSmoothie.find_by_sql <<-SQL, :repository => ENV['ADAPTER'].intern
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          found.repository.should == DataMapper.repository(ENV['ADAPTER'].intern)
        end

        it 'should use the default repository if no repository option is specified' do
          found = GreenSmoothie.find_by_sql <<-SQL
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          found.repository.should == DataMapper.repository(:default)
        end
      end

      describe ':reload option' do
        it 'should reload existing resources in the identity map if given true' do
          found = GreenSmoothie.find_by_sql <<-SQL, :reload => true
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          found.query.reload?.should be_true
        end

        it 'should not reload existing resources in the identity map if given false' do
          found = GreenSmoothie.find_by_sql <<-SQL, :reload => false
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          found.query.reload?.should be_false
        end

        it 'should default to false' do
          found = GreenSmoothie.find_by_sql <<-SQL
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          found.query.reload?.should be_false
        end
      end

      describe ':properties option' do
        it 'should accept an array of symbols' do
          found = GreenSmoothie.find_by_sql <<-SQL, :properties => [:id, :name]
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          properties = found.first.loaded_properties
          properties.should have(2).properties
          properties.should include(GreenSmoothie.properties[:id])
          properties.should include(GreenSmoothie.properties[:name])
        end

        it 'should accept a single Symbol' do
          found = GreenSmoothie.find_by_sql <<-SQL, :properties => :id
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          properties = found.first.loaded_properties
          properties.should have(1).properties
          properties.should include(GreenSmoothie.properties[:id])
        end

        it 'should accept a PropertySet' do
          found = GreenSmoothie.find_by_sql <<-SQL, :properties => GreenSmoothie.properties
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          properties = found.first.loaded_properties
          properties.should have(2).properties
          properties.should include(GreenSmoothie.properties[:id])
          properties.should include(GreenSmoothie.properties[:name])
        end

        it 'should accept a single property' do
          found = GreenSmoothie.find_by_sql <<-SQL, :properties => GreenSmoothie.properties[:id]
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          properties = found.first.loaded_properties
          properties.should have(1).property
          properties.first.should == GreenSmoothie.properties[:id]
        end

        it 'should accept an array of Properties' do
          found = GreenSmoothie.find_by_sql <<-SQL, :properties => GreenSmoothie.properties.to_a
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          properties = found.first.loaded_properties
          properties.should have(2).properties
          properties.should include(GreenSmoothie.properties[:id])
          properties.should include(GreenSmoothie.properties[:name])
        end

        it 'should use the given properties in preference over those in the SQL query' do
          found = GreenSmoothie.find_by_sql <<-SQL, :properties => GreenSmoothie.properties
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          properties = found.first.loaded_properties
          properties.should have(2).properties
          properties.should include(GreenSmoothie.properties[:id])
          properties.should include(GreenSmoothie.properties[:name])
        end

        it 'should use the default properties if none are specified' do
          found = GreenSmoothie.find_by_sql <<-SQL
            SELECT id, name FROM green_smoothies LIMIT 1
          SQL

          found.first.loaded_properties.should == GreenSmoothie.properties
        end
      end
    end # find_by_sql

  end
end
