$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'

describe 'A Connection instance' do

  before do
    @connection = DataMapperRest::Connection.new({:adapter  => 'rest', :format => 'xml', :host => 'localhost', :port => '4000', :login => 'admin', :password => 'secret'})
  end
  
  it "should construct a valid uri" do
    @connection.uri.to_s.should == "http://admin:secret@localhost:4000"
    @connection.uri.host.should == "localhost"
    @connection.uri.port.should == 4000
    @connection.uri.user.should == "admin"
    @connection.uri.password.should == "secret"
  end
  
  it "should return the correct extension and mime type for xml" do
    @connection.format.header.should == {'Content-Type' => "application/xml"}
  end
  
  it "should return the correct extension and mime type for json" do
    connection = DataMapperRest::Connection.new({:adapter  => 'rest', :format => 'json', :host => 'localhost', :port => '4000', :login => 'admin', :password => 'secret'})
    connection.format.header.should == {'Content-Type' => "application/json"}
  end

  describe 'when running the verb methods' do

    it 'should make an HTTP Post' do
      @connection.should_receive(:run_verb).with("post", "<somexml>")
      @connection.http_post("foobars", "<somexml>")
    end

    it 'should make an HTTP Get' do
      @connection.should_receive(:run_verb).with("get", "<somexml>")
      @connection.http_get("foobars", "<somexml>")
    end

    it 'should make an HTTP Put' do
      @connection.should_receive(:run_verb).with("put", "<somexml>")
      @connection.http_put("foobars", "<somexml>")
    end
    
    it 'should make an HTTP Delete' do
      @connection.should_receive(:run_verb).with("delete", "<somexml>")
      @connection.http_delete("foobars", "<somexml>")
    end
  end
end
