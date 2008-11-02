require(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Sweatshop::Unique do
  before(:each) do
    @ss = DataMapper::Sweatshop::Unique
    @ss.reset!
  end

  describe '#unique' do
    it 'for the same block, passes an incrementing value' do
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
    end

    it 'for the different blocks, passes separately incrementing values' do
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
      (1..3).to_a.collect { @ss.unique {|x| "b#{x}"} }.should ==
        %w(b0 b1 b2)
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a3 a4 a5)
    end

    it 'allows an optional key to be specified' do
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
      (1..3).to_a.collect { @ss.unique(:a) {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
    end

    describe 'when ParseTree is unavilable' do
      it 'raises when no key is provided' do
        Object.stub!(:const_defined?).with("ParseTree").and_return(false)
        lambda {
          @ss.unique {}
        }.should raise_error
      end

      it 'does not raise when a key is provided' do
        lambda {
          @ss.unique(:a) {}
        }.should_not raise_error
      end
    end
  end
end
