require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize do
  def self.each_method(message, &block)
    [Harness::ToXml, Harness::ToJson].collect {|x| x.new }.each do |harness|
      describe "##{harness.method_name}" do
        it(message) do
          self.class.send(:define_method, :harness) do
            harness
          end
          self.instance_eval(&block)
        end
      end
    end
  end

  each_method "serializes values returned by methods given to :methods option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(harness.method_name, :methods => [:category, :has_known_form_of_life?])
    
    harness.extract_value(result, "category").should == "terrestrial"
    harness.extract_value(result, "has_known_form_of_life?").should be(false)
  end

  each_method "only includes properties given to :only option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(harness.method_name, :only => [:name])

    harness.extract_value(result, "name").should == "Mars"
    harness.extract_value(result, "aphelion").should be(nil)
  end

  each_method "excludes properties given to :exclude option" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(harness.method_name, :exclude => [:aphelion])

    harness.extract_value(result, "name").should == "Mars"
    harness.extract_value(result, "aphelion").should be(nil)
  end

  each_method "has higher precendence for :only option over :exclude" do
    result = Planet.new(
      :name     => "Mars",
      :aphelion => 249_209_300.4
    ).send(harness.method_name, :only => [:name], :exclude => [:name])

    harness.extract_value(result, "name").should == "Mars"
    harness.extract_value(result, "aphelion").should be(nil)
  end
end
