require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-aggregates'

begin

  require 'do_sqlite3'

  DB_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/integration_test.db'
  FileUtils.touch DB_PATH

  LOG_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/sql.log'
  FileUtils.touch LOG_PATH
  DataMapper::Logger.new(LOG_PATH, 0)
  at_exit { DataMapper.logger.close }

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe "Aggregates" do
    before(:all) do

      repository(:sqlite3).adapter.execute(<<-EOS.compress_lines) rescue nil
        DROP TABLE 'dragons';
        CREATE TABLE 'dragons' (
          "id" INT PRIMARY KEY,
          "name" VARCHAR(30),
          "is_fire_breathing" TINYINT,
          "toes_on_claw" SMALLINT(3)
        );
      EOS
      
      class Dragon
        include DataMapper::Resource
        property :id, Fixnum, :serial => true
        property :name, String
        property :is_fire_breathing, TrueClass
        property :toes_on_claw, Fixnum
      end
     

      repository(:sqlite3) do 
        Dragon.new(:name => 'George', :is_fire_breathing => false, :toes_on_claw => 3).save
        Dragon.new(:name => 'Puff', :is_fire_breathing => true, :toes_on_claw => 4).save
        Dragon.new(:name => 'Anzu', :is_fire_breathing => true, :toes_on_claw => 5).save
      end
    end

    it "should count" do
      lambda do
        repository(:sqlite3) do
          Dragon.count()
        end
      end.should_not raise_error

      result = repository(:sqlite3) do
        Dragon.count()
      end
      result.should eql(3)
    end

    it "should count with conditions" do
      repository(:sqlite3) do
        result = Dragon.count(:conditions => ['is_fire_breathing = ?', false])
        result.should eql(1)

        result = Dragon.count(:conditions => ['is_fire_breathing = ?', true])
        result.should eql(2)
      end
    end
  end

rescue LoadError
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "aggregates specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
