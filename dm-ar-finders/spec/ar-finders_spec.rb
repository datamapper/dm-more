require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-ar-finders'

begin

  require 'do_sqlite3'
  require 'pp'

  DB_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/integration_test.db'
  FileUtils.touch DB_PATH
  
  LOG_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/sql.log'
  FileUtils.touch LOG_PATH
  DataMapper::Logger.new(LOG_PATH, 0)
  at_exit { DataMapper.logger.close }
  
  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")
  
  describe "DataMapper::Resource" do  
    after do
     repository(:sqlite3).adapter.execute('DELETE from green_smoothies');
    end

    before(:all) do
      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        CREATE TABLE "green_smoothies" (
          "id" INTEGER PRIMARY KEY,
          "name" VARCHAR(50)
        )
      EOS

      class GreenSmoothie
        include DataMapper::Resource
        property :id, Fixnum, :serial => true
        property :name, String
      end    
    end
      
    it "should find/create using find_or_create" do
      repository(:sqlite3) do
        green_smoothie = GreenSmoothie.new(:name => 'Banana')
        green_smoothie.save
        GreenSmoothie.find_or_create({:name => 'Banana'}).id.should eql(green_smoothie.id)
        GreenSmoothie.find_or_create({:name => 'Strawberry'}).id.should eql(2)
      end
    end
    
    it "should find_by_name" do
      repository(:sqlite3) do
        green_smoothie = GreenSmoothie.create({:name => 'Banana'})
        green_smoothie.should == GreenSmoothie.find_by_name('Banana')
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
