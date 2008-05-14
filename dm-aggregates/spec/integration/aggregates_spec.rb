require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Resource' do
    before :all do
      # A simplistic example, using with an Integer property
      class Dragon
        include DataMapper::Resource
        property :id, Integer, :serial => true
        property :name, String
        property :is_fire_breathing, TrueClass
        property :toes_on_claw, Integer

        auto_migrate!(:default)
      end

      Dragon.create(:name => 'George', :is_fire_breathing => false, :toes_on_claw => 3)
      Dragon.create(:name => 'Puff',   :is_fire_breathing => true,  :toes_on_claw => 4)
      Dragon.create(:name => nil,      :is_fire_breathing => true,  :toes_on_claw => 5)

      # A more complex example, with BigDecimal and Float properties
      # Statistics taken from CIA World Factbook:
      # https://www.cia.gov/library/publications/the-world-factbook/
      class Country
        include DataMapper::Resource

        property :id,                  Integer, :serial => true
        property :name,                String,  :nullable => false
        property :population,          Integer
        property :birth_rate,          Float,      :scale => 4,  :precision => 2
        property :gold_reserve_tonnes, Float,      :scale => 6,  :precision => 2
        property :gold_reserve_value,  BigDecimal, :scale => 15, :precision => 1  # approx. value in USD

        auto_migrate!(:default)
      end

      gold_kilo_price  = 277738.70
      @gold_tonne_price = gold_kilo_price * 10000

      Country.create(:name => 'China',
                      :population => 1330044605,
                      :birth_rate => 13.71,
                      :gold_reserve_tonnes => 600.0,
                      :gold_reserve_value  => 600.0 * @gold_tonne_price) #  32150000
      Country.create(:name => 'United States',
                      :population => 303824646,
                      :birth_rate => 14.18,
                      :gold_reserve_tonnes => 8133.5,
                      :gold_reserve_value  => 8133.5 * @gold_tonne_price)
      Country.create(:name => 'Brazil',
                      :population => 191908598,
                      :birth_rate => 16.04,
                      :gold_reserve_tonnes => nil) # example of no stats available
      Country.create(:name => 'Russia',
                      :population => 140702094,
                      :birth_rate => 11.03,
                      :gold_reserve_tonnes => 438.2,
                      :gold_reserve_value  => 438.2 * @gold_tonne_price)
      Country.create(:name => 'Japan',
                      :population => 127288419,
                      :birth_rate => 7.87,
                      :gold_reserve_tonnes => 765.2,
                      :gold_reserve_value  => 765.2 * @gold_tonne_price)
      Country.create(:name => 'Mexico',
                      :population => 109955400,
                      :birth_rate => 20.04,
                      :gold_reserve_tonnes => nil) # example of no stats available
      Country.create(:name => 'Germany',
                      :population => 82369548,
                      :birth_rate => 8.18,
                      :gold_reserve_tonnes => 3417.4,
                      :gold_reserve_value  => 3417.4 * @gold_tonne_price)

      @approx_by = 0.000001
    end

    describe '.count' do
      describe 'with no arguments' do
        it 'should count the results' do
          Dragon.count.should  == 3

          Country.count.should == 7
        end

        it 'should count the results with conditions having operators' do
          Dragon.count(:toes_on_claw.gt => 3).should == 2

          Country.count(:birth_rate.lt => 12).should == 3
          Country.count(:population.gt => 1000000000).should == 1
          Country.count(:population.gt => 2000000000).should == 0
          Country.count(:population.lt => 10).should == 0
        end

        it 'should count the results with raw conditions' do
          dragon_statement = 'is_fire_breathing = ?'
          Dragon.count(:conditions => [ dragon_statement, false ]).should == 1
          Dragon.count(:conditions => [ dragon_statement, true  ]).should == 2
        end
      end

      describe 'with a property name' do
        it 'should count the results' do
          Dragon.count(:name).should == 2
        end

        it 'should count the results with conditions having operators' do
          Dragon.count(:name, :toes_on_claw.gt => 3).should == 1
        end

        it 'should count the results with raw conditions' do
          statement = 'is_fire_breathing = ?'
          Dragon.count(:name, :conditions => [ statement, false ]).should == 1
          Dragon.count(:name, :conditions => [ statement, true  ]).should == 1
        end
      end
    end

    describe '.min' do
      describe 'with no arguments' do
        it 'should raise an error' do
          lambda { Dragon.min }.should raise_error(ArgumentError)
        end
      end

      describe 'with a property name' do
        it 'should provide the lowest value of an Integer property' do
          Dragon.min(:toes_on_claw).should == 3
          Country.min(:population).should == 82369548
        end

        it 'should provide the lowest value of a Float property' do
          Country.min(:birth_rate).should be_kind_of(Float)
          Country.min(:birth_rate).should >= 7.87 - @approx_by  # approx match
          Country.min(:birth_rate).should <= 7.87 + @approx_by  # approx match
        end

        it 'should provide the lowest value of a BigDecimal property' do
          pending 'Does not provide correct results with SQLite3' if HAS_SQLITE3
          Country.min(:gold_reserve_value).should be_kind_of(BigDecimal)
          Country.min(:gold_reserve_value).should == BigDecimal('1217050983400.0')
        end

        it 'should provide the lowest value when conditions provided' do
          Dragon.min(:toes_on_claw, :is_fire_breathing => true).should  == 4
          Dragon.min(:toes_on_claw, :is_fire_breathing => false).should == 3
        end
      end
    end

    describe '.max' do
      describe 'with no arguments' do
        it 'should raise an error' do
          lambda { Dragon.max }.should raise_error(ArgumentError)
        end
      end

      describe 'with a property name' do
        it 'should provide the highest value of an Integer property' do
          Dragon.max(:toes_on_claw).should == 5
          Country.max(:population).should == 1330044605
        end

        it 'should provide the highest value of a Float property' do
          Country.max(:birth_rate).should be_kind_of(Float)
          Country.max(:birth_rate).should >= 20.04 - @approx_by  # approx match
          Country.max(:birth_rate).should <= 20.04 + @approx_by  # approx match
        end

        it 'should provide the highest value of a BigDecimal property' do
          pending 'Does not provide correct results with SQLite3' if HAS_SQLITE3
          Country.max(:gold_reserve_value).should == BigDecimal('22589877164500.0')
        end

        it 'should provide the highest value when conditions provided' do
          Dragon.max(:toes_on_claw, :is_fire_breathing => true).should  == 5
          Dragon.max(:toes_on_claw, :is_fire_breathing => false).should == 3
        end
      end
    end

    describe '.avg' do
      describe 'with no arguments' do
        it 'should raise an error' do
          lambda { Dragon.avg }.should raise_error(ArgumentError)
        end
      end

      describe 'with a property name' do
        it 'should provide the average value of an Integer property' do
          Dragon.avg(:toes_on_claw).should == 4
        end

        it 'should provide the average value of a Float property' do
          mean_birth_rate = (13.71 + 14.18 + 16.04 + 11.03 + 7.87 + 20.04 + 8.18) / 7
          Country.avg(:birth_rate).should be_kind_of(Float)
          Country.avg(:birth_rate).should >= mean_birth_rate - @approx_by  # approx match
          Country.avg(:birth_rate).should <= mean_birth_rate + @approx_by  # approx match
        end

        it 'should provide the average value of a BigDecimal property' do
          mean_gold_reserve_value = ((600.0 + 8133.50 + 438.20 + 765.20 + 3417.40) * @gold_tonne_price) / 5
          Country.avg(:gold_reserve_value).should be_kind_of(BigDecimal)
          Country.avg(:gold_reserve_value).should == BigDecimal(mean_gold_reserve_value.to_s)
        end

        it 'should provide the average value when conditions provided' do
          Dragon.avg(:toes_on_claw, :is_fire_breathing => true).should  == 4
          Dragon.avg(:toes_on_claw, :is_fire_breathing => false).should == 3
        end
      end
    end

    describe '.sum' do
      describe 'with no arguments' do
        it 'should raise an error' do
          lambda { Dragon.sum }.should raise_error(ArgumentError)
        end
      end

      describe 'with a property name' do
        it 'should provide the sum of values for an Integer property' do
          pending 'Does not provide correct results with SQLite3' if HAS_SQLITE3
          Dragon.sum(:toes_on_claw).should == 12

          total_population = 1330044605 + 303824646 + 191908598 + 140702094 +
                             127288419 + 109955400 + 82369548
          Country.sum(:population).should == total_population
        end

        it 'should provide the sum of values for a Float property' do
          total_tonnes = 600.0 + 8133.5 + 438.2 + 765.2 + 3417.4
          Country.sum(:gold_reserve_tonnes).should be_kind_of(Float)
          Country.sum(:gold_reserve_tonnes).should >= total_tonnes - @approx_by  # approx match
          Country.sum(:gold_reserve_tonnes).should <= total_tonnes + @approx_by  # approx match
        end

        it 'should provide the sum of values for a BigDecimal property' do
          pending 'Does not provide correct results with SQLite3' if HAS_SQLITE3
          Country.sum(:gold_reserve_value).should == BigDecimal('37090059214100.0')
        end

        it 'should provide the average value when conditions provided' do
          Dragon.sum(:toes_on_claw, :is_fire_breathing => true).should  == 9
          Dragon.sum(:toes_on_claw, :is_fire_breathing => false).should == 3
        end
      end
    end
  end
end
