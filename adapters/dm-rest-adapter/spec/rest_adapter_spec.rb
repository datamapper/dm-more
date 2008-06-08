require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/rest_adapter'

DataMapper.setup(:rest, {
  :adapter  => 'rest',
  :format => 'xml',
  :base_url => 'http://whatever.com/api'
})


describe "The REST Adapter" do
  it "should have some specs"
end