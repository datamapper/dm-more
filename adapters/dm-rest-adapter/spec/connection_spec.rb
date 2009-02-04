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
  
  describe "when receiving error response codes" do
    
    before do
      @mock_http = mock("http")
      Net::HTTP.should_receive(:start).with(@connection.uri.host, @connection.uri.port).and_yield @mock_http
    end
    
    it "should raise 404" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 404, "oops")
      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::ResourceNotFound, "Resource action failed with code: 404, message: oops")
    end

    it "should redirect on 301" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 301, "moved")
      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::Redirection, "Resource action failed with code: 301, message: moved")
    end
    
    it "should redirect on 302" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 302, "moved")
      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::Redirection, "Resource action failed with code: 302, message: moved")
    end
    
    it "should raise bad request on 400" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 400, "bad mojo")

      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::BadRequest, "Resource action failed with code: 400, message: bad mojo")
    end
    
    it "should raise MethodNotAllowed on 405" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 405, "nope zero")

      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::MethodNotAllowed, "Resource action failed with code: 405, message: nope zero")
    end
    
    it "should raise ResourceConflict on 409" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 409, "should I stay or should I go")

      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::ResourceConflict, "Resource action failed with code: 409, message: should I stay or should I go")
    end
    
    it "should raise ResourceInvalid on 422" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 422, "WTF")

      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::ResourceInvalid, "Resource action failed with code: 422, message: WTF")
    end
    
    it "should raise ClientError on 401" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 401, "no idea")

      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::ClientError, "Resource action failed with code: 401, message: no idea")
    end
    
    it "should raise ServerError on 500" do
      @mock_http.should_receive(:request).and_return Net::HTTPResponse.new(1, 500, "I broken")

      lambda {@connection.http_post("foobars", "<somexml>")}.should raise_error(DataMapperRest::ServerError, "Resource action failed with code: 500, message: I broken")
    end
    
  end
end
