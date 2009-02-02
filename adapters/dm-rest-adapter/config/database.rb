DataMapper.setup(:default, {
  :adapter  => 'rest',
  :format => 'xml',
  :host => 'localhost',
  :port => '3001'
})