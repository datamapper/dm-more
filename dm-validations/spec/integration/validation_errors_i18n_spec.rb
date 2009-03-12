require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Validate::ValidationErrors do
  it "should not detect the presence of the I18n module the first time it's called" do
    DataMapper::Validate::ValidationErrors.i18n_present?.should == false
  end
  
  it "should return the message with the humanized field" do
    DataMapper::Validate::ValidationErrors.default_error_message(:absent, 'fake_property').should == 'Fake property must be absent'
  end
end
