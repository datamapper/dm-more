require File.expand_path(File.join(File.dirname(__FILE__), <%= ([ "'..'" ] * class_nesting_depth).join(', ') %>, '..', 'spec_helper')

describe <%= class_name %> do
  before(:each) do
    @<%= file_name %> = <%= class_name %>.new
  end

  it 'should be awesome'
end
