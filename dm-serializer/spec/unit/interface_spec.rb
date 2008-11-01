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
end
