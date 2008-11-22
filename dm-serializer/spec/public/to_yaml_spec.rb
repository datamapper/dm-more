require 'pathname'
require 'yaml'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_yaml' do
  #
  # ==== yummy YAML
  #

  before(:all) do
    @harness = Class.new(SerializerTestHarness) do
      def method_name
        :to_yaml
      end

      protected

      def deserialize(result)
        stringify_keys = lambda {|hash| hash.inject({}) {|a, (key, value)| a.update(key.to_s => value) }}
        result = YAML.load(result)
        if result.is_a?(Array)
          result.collect(&stringify_keys)
        else
          stringify_keys[result]
        end
      end
    end.new
  end

  it_should_behave_like "A serialization method"

end
