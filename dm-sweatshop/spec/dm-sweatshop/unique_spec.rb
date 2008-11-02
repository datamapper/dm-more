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
    end

    it 'allows an optional key to be specified' do
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
      (1..3).to_a.collect { @ss.unique(:a) {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
    end
  end
end
