require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

if HAS_SQLITE3
  describe DataMapper::Validate::ValidationErrors do
    it "should have specs" do
      pending
      # FIXME do something, add specs
    end
  end
end
