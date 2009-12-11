require 'spec_helper'
require 'integration/method_validator/spec_helper'

describe "a good fit for DSLs", :shared => true do
  it "is a good fit for DSLs" do
    @model.should be_valid_for_implementing_a_dsl
  end

  it "is totally fine for DSLs" do
    @model.ensure_appropriate_for_dsls.should be_true
  end
end

describe "a poor candidate for DSLs", :shared => true do
  it "is a poor candidate for DSLs" do
    @model.should_not be_valid_for_implementing_a_dsl
  end

  it "is unappropriate for DSLs" do
    @model.ensure_appropriate_for_dsls.first.should be_false
  end

  it "has a (more or less) meaningful error message" do
    @model.errors.on(:ensure_appropriate_for_dsls).should == [ 'may not be so good for domain specific languages' ]
  end
end


describe "a good fit for game engine core", :shared => true do
  it "is a good fit for game engine core" do
    @model.should be_valid_for_implementing_a_game_engine_core
  end

  it "is appropriate for system programming" do
    @model.ensure_appropriate_for_system_programming.should be_true
  end
end

describe "a poor candidate for game engine core", :shared => true do
  it "is a poor candidate for game engine core" do
    @model.should_not be_valid_for_implementing_a_game_engine_core
  end
end



describe "a good fit for kernel hacking", :shared => true do
  it "is a good fit for kernel hacking" do
    @model.should be_valid_for_hacking_on_the_kernel
  end

  it "is appropriate for system programming" do
    @model.ensure_appropriate_for_system_programming.should be_true
  end
end


describe "a poor candidate for kernel hacking", :shared => true do
  it "is not a good fit for kernel hacking" do
    @model.should_not be_valid_for_hacking_on_the_kernel
  end
end

#
# Note that ProgrammingLanguage is not a DM resource,
# it is a plain old Ruby object (PORO), or simply put,
# just a "regular" Ruby class with a bunch of accessors.
#
# And yes, assumptions below are full of bullshit and
# author is a moron, and your favourite programming
# language is good for EVARYTHIN'!
#
#Please see spec_helper.rb next to this file
#

describe "C" do
  before :all do
    @model = ::DataMapper::Validate::Fixtures::ProgrammingLanguage.new(:name                                     => "C",
                                                                       :allows_system_calls                      => true,
                                                                       :allows_manual_memory_management          => true,
                                                                       :approved_by_linus                        => true,
                                                                       :compiler_excels_at_utilizing_cpu_cache   => true,
                                                                       :is_very_high_level                       => false,
                                                                       :does_not_require_explicit_return_keyword => false,
                                                                       :allows_operator_overload                 => false,
                                                                       :allows_optional_parentheses              => false
                                                                       )
  end

  it_should_behave_like "a good fit for kernel hacking"

  it_should_behave_like "a good fit for game engine core"

  it_should_behave_like "a poor candidate for DSLs"
end



describe "C++" do
  before :all do
    @model = ::DataMapper::Validate::Fixtures::ProgrammingLanguage.new(:name                                     => "C++",
                                                                       :allows_system_calls                      => true,
                                                                       :allows_manual_memory_management          => true,
                                                                       :approved_by_linus                        => false,
                                                                       :compiler_excels_at_utilizing_cpu_cache   => true,
                                                                       :is_very_high_level                       => false,
                                                                       :does_not_require_explicit_return_keyword => false,
                                                                       :allows_operator_overload                 => true,
                                                                       :allows_optional_parentheses              => false
                                                                       )
  end

  it_should_behave_like "a poor candidate for kernel hacking"

  it_should_behave_like "a good fit for game engine core"

  it_should_behave_like "a poor candidate for DSLs"

  it "is not approved by Linus" do
    @model.valid?(:hacking_on_the_kernel)
    @model.errors.on(:ensure_approved_by_linus_himself).should_not be_blank
  end
end


describe "Ruby" do
  before :all do
    @model = ::DataMapper::Validate::Fixtures::ProgrammingLanguage.new(:name                                     => "Ruby",
                                                                       # well, C extensions do not really count
                                                                       :allows_system_calls                      => false,
                                                                       :allows_manual_memory_management          => false,
                                                                       :approved_by_linus                        => false,
                                                                       :compiler_excels_at_utilizing_cpu_cache   => false,
                                                                       :is_very_high_level                       => true,
                                                                       :does_not_require_explicit_return_keyword => true,
                                                                       :allows_operator_overload                 => true,
                                                                       :allows_optional_parentheses              => true
                                                                       )
  end

  it_should_behave_like "a good fit for DSLs"

  it_should_behave_like "a poor candidate for kernel hacking"

  it_should_behave_like "a poor candidate for game engine core"

  it "has a (more or less) meaningful error message" do
    @model.valid?(:doing_system_programming)
    @model.errors.on(:ensure_appropriate_for_system_programming).should == [ 'try something that is closer to the metal' ]
  end
end


describe "Scala" do
  before :all do
    @model = ::DataMapper::Validate::Fixtures::ProgrammingLanguage.new(:name                                     => "Scala",
                                                                       :allows_system_calls                      => false,
                                                                       :allows_manual_memory_management          => false,
                                                                       :approved_by_linus                        => false,
                                                                       :compiler_excels_at_utilizing_cpu_cache   => false,
                                                                       :is_very_high_level                       => true,
                                                                       :does_not_require_explicit_return_keyword => true,
                                                                       :allows_operator_overload                 => true,
                                                                       :allows_optional_parentheses              => true
                                                                       )
  end

  it_should_behave_like "a good fit for DSLs"

  it_should_behave_like "a poor candidate for kernel hacking"

  it_should_behave_like "a poor candidate for game engine core"

  it "has a (more or less) meaningful error message" do
    @model.valid?(:doing_system_programming)
    @model.errors.on(:ensure_appropriate_for_system_programming).should == [ 'try something that is closer to the metal' ]
  end
end



describe "Haskell" do
  before :all do
    @model = ::DataMapper::Validate::Fixtures::ProgrammingLanguage.new(:name                                     => "Haskell",
                                                                       :allows_system_calls                      => false,
                                                                       :allows_manual_memory_management          => false,
                                                                       :approved_by_linus                        => false,
                                                                       :compiler_excels_at_utilizing_cpu_cache   => true,
                                                                       :is_very_high_level                       => true,
                                                                       :does_not_require_explicit_return_keyword => true,
                                                                       # operators are not different from any other function
                                                                       :allows_operator_overload                 => true,
                                                                       # or, allows explicit parentheses? who cares, we
                                                                       # are just trying to come up with a relatively
                                                                       # non-stupid spec example
                                                                       :allows_optional_parentheses              => true
                                                                       )
  end

  it_should_behave_like "a good fit for DSLs"

  it_should_behave_like "a poor candidate for kernel hacking"

  it_should_behave_like "a poor candidate for game engine core"

  it "has a (more or less) meaningful error message" do
    @model.valid?(:doing_system_programming)
    @model.errors.on(:ensure_appropriate_for_system_programming).should == [ 'try something that is closer to the metal' ]
  end
end


describe 'DataMapper::Validate::Fixtures::Event' do
  before :all do
    DataMapper::Validate::Fixtures::Event.auto_migrate!

    @model = DataMapper::Validate::Fixtures::Event.new(:name => "Fools day 2009")
  end

  describe "with start time before end time" do
    before :all do
      @model.starts_at = DateTime.new(2009, 4, 1, 00, 00, 01)
      @model.ends_at   = DateTime.new(2009, 4, 1, 23, 59, 59)
    end

    it_should_behave_like "valid model"
  end

  describe "with start time after end time" do
    before :all do
      @model.starts_at = DateTime.new(2009, 4, 1, 23, 59, 59)
      @model.ends_at   = DateTime.new(2009, 4, 1, 00, 00, 01)
    end

    it_should_behave_like "invalid model"

    it "uses custom error message for property starts_at" do
      @model.errors.on(:starts_at).should == [ 'Start time cannot be after end time' ]
    end
  end
end
