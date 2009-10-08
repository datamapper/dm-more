require 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe DataMapper::Collection do
    it_should_behave_like 'It Has Setup Resources'

    before :all do
      @dragons   = Dragon.all
      @countries = Country.all
    end

    it_should_behave_like 'An Aggregatable Class'

    describe 'ignore invalid query' do
      before :all do
        @dragons = @dragons.all(:id => [])
      end

      [ :size, :count ].each do |method|
        describe "##{method}" do
          it 'should return 0' do
            @dragons.send(method).should == 0
          end
        end
      end

      describe '#min' do
        it 'should return nil' do
          @dragons.min(:id).should == nil
        end
      end

      describe '#max' do
        it 'should return nil' do
          @dragons.max(:id).should == nil
        end
      end

      describe '#avg' do
        it 'should return nil' do
          @dragons.avg(:id).should == nil
        end
      end

      describe '#sum' do
        it 'should return nil' do
          @dragons.sum(:id).should == nil
        end
      end

      describe '#aggregate' do
        it 'should return nil' do
          @dragons.aggregate(:id).should == []
        end
      end
    end
  end
end
