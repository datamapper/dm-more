require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'


describe DataMapper::Types::Yaml, ".load" do
  describe "when nil is provided" do
    it 'returns nil' do
      DataMapper::Types::Yaml.load(nil, :property).should be_nil
    end
  end

  describe "when YAML encoded primitive string is provided" do
    it 'returns decoded value as Ruby string' do
      DataMapper::Types::Yaml.load("--- yaml string\n", :property).should == "yaml string"
    end
  end

  describe "when something else is provided" do
    it 'raises ArgumentError with a meaningful message' do
      lambda {
        DataMapper::Types::Yaml.load(:sym, :property)
      }.should raise_error(ArgumentError, "+value+ of a property of YAML type must be nil or a String")
    end
  end
end



describe DataMapper::Types::Yaml, ".dump" do
  describe "when nil is provided" do
    it 'returns nil' do
      DataMapper::Types::Yaml.dump(nil, :property).should be_nil
    end
  end

  describe "when YAML encoded primitive string is provided" do
    it 'does not do double encoding' do
      DataMapper::Types::Yaml.dump("--- yaml encoded string\n", :property).should == "--- yaml encoded string\n"
    end
  end

  describe "when regular Ruby string is provided" do
    it 'dumps argument to YAML' do
      DataMapper::Types::Yaml.dump("dump me (to yaml)", :property).should == "--- dump me (to yaml)\n"
    end
  end

  describe "when Ruby array is provided" do
    it 'dumps argument to YAML' do
      DataMapper::Types::Yaml.dump([1, 2, 3], :property).should == "--- \n- 1\n- 2\n- 3\n"
    end
  end

  describe "when Ruby hash is provided" do
    it 'dumps argument to YAML' do
      DataMapper::Types::Yaml.dump({ :datamapper => "Data access layer in Ruby" }, :property).should == "--- \n:datamapper: Data access layer in Ruby\n"
    end
  end
end



describe DataMapper::Types::Yaml, ".typecast" do
  it 'leaves the value unchanged' do
    @type = DataMapper::Types::Yaml
    @type.typecast([1, 2, 3], :property).should == [1, 2, 3]

    class SerializeMe
      attr_accessor :name
    end

    obj = SerializeMe.new
    obj.name = 'Hello!'

    casted = @type.typecast(obj, :property)
    casted.should be_kind_of(SerializeMe)
    casted.name.should == 'Hello!'
  end
end
