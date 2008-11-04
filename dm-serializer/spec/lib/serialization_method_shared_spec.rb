require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

share_examples_for 'A serialization method' do
  before do
    %w[ @harness ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_get(ivar)
    end
  end

  it "only includes properties given to :only option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :only => [:name])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end

  it "serializes values returned by methods given to :methods option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :methods => [:category, :has_known_form_of_life?])
    
    @harness.extract_value(result, "category").should == "terrestrial"
    @harness.extract_value(result, "has_known_form_of_life?").should be(false)
  end

  it "only includes properties given to :only option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :only => [:name])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end

  it "excludes properties given to :exclude option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :exclude => [:aphelion])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end

  it "has higher precendence for :only option over :exclude" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(@harness.method_name, :only => [:name], :exclude => [:name])

    @harness.extract_value(result, "name").should == "Mars"
    @harness.extract_value(result, "aphelion").should be(nil)
  end
end
