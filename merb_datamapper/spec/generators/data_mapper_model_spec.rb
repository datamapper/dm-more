require File.join(File.dirname(__FILE__), 'spec_helper')
describe "Merb::Generators::ModelGenerator for DataMapper" do
  it "complains if no name is specified" do
    lambda {
      @generator = Merb::Generators::ModelGenerator.new('/tmp', {:orm => :datamapper})
    }.should raise_error(::Templater::TooFewArgumentsError)
  end


  before do
    @generator = Merb::Generators::ModelGenerator.new('/tmp',{:orm => :datamapper}, 'Stuff')
  end

  it_should_behave_like "namespaced generator"

  it "should create a model" do
    @generator.should create('/tmp/app/models/stuff.rb')
  end

  it "should render successfully" do
    lambda { @generator.render! }.should_not raise_error
  end
end
