require 'spec_helper'

describe DataMapper::Adapters::RestAdapter do
  before :all do
    @adapter = DataMapper::Repository.adapters[:default]
  end

  after :all do
    FakeWeb.clean_registry
  end

  describe '#create' do
    describe 'when provided a Resource' do
      before :all do
        body = <<-XML.compress_lines
          <book>
            <id type='datamapper::types::serial'>1</id>
            <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
            <title>DataMapper</title>
            <author>Dan Kubb</author>
          </book>
        XML

        headers = { 'Content-Length' => body.respond_to?(:bytesize) ? body.bytesize : body.size }

        FakeWeb.register_uri(:post, 'http://admin:secret@localhost:4000/books.xml', :status => 200, :headers => headers, :body => body)
      end

      before :all do
        @resource  = Book.new(:created_at => DateTime.parse('2009-05-17T22:38:42-07:00'), :title => 'DataMapper', :author => 'Dan Kubb')
        @resources = [ @resource ]

        @response = @adapter.create(@resources)
      end

      it 'should return an Array containing the Resource' do
        @response.should equal(@resources)
      end

      it 'should set the identity field' do
        @resource.id.should == 1
      end
    end
  end

  describe '#read' do
    describe 'with unscoped query' do
      before :all do
        body = <<-XML.compress_lines
          <books>
            <book>
              <id type='datamapper::types::serial'>1</id>
              <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
              <title>DataMapper</title>
              <author>Dan Kubb</author>
            </book>
          </books>
        XML

        headers = { 'Content-Length' => body.respond_to?(:bytesize) ? body.bytesize : body.size }

        FakeWeb.register_uri(:get, 'http://admin:secret@localhost:4000/books.xml', :status => 200, :headers => headers, :body => body)
      end

      before :all do
        @query = Book.all.query

        @response = @adapter.read(@query)
      end

      it 'should return an Array with the matching Records' do
        @response.should == [ { 'id' => 1, 'created_at' => DateTime.parse('2009-05-17T22:38:42-07:00'), 'title' => 'DataMapper', 'author' => 'Dan Kubb' } ]
      end
    end

    describe 'with query scoped by a key' do
      before :all do

      end


      before :all do
        @query = Book.all(:id => 1, :limit => 1).query

        body = <<-XML.compress_lines
          <book>
            <id type='datamapper::types::serial'>1</id>
            <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
            <title>DataMapper</title>
            <author>Dan Kubb</author>
          </book>
        XML

        headers = { 'Content-Length' => body.respond_to?(:bytesize) ? body.bytesize : body.size }

        FakeWeb.register_uri(:get, 'http://admin:secret@localhost:4000/books/1.xml', :status => 200, :headers => headers, :body => body)

        @response = @adapter.read(@query)
      end

      it 'should return an Array with the matching Records' do
        @response.should == [ { 'id' => 1, 'created_at' => DateTime.parse('2009-05-17T22:38:42-07:00'), 'title' => 'DataMapper', 'author' => 'Dan Kubb' } ]
      end
    end

    describe 'with query scoped by a non-key' do
      before :all do
        body = <<-XML.compress_lines
          <books>
            <book>
              <id type='datamapper::types::serial'>1</id>
              <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
              <title>DataMapper</title>
              <author>Dan Kubb</author>
            </book>

            <!-- provide an extra resource, which should be filtered out -->
            <book>
              <id type='datamapper::types::serial'>2</id>
              <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
              <title>DataMapper</title>
              <author>John Doe</author>
            </book>
          </books>
        XML

        headers = { 'Content-Length' => body.respond_to?(:bytesize) ? body.bytesize : body.size }

        FakeWeb.register_uri(:get, 'http://admin:secret@localhost:4000/books.xml?author=Dan+Kubb', :status => 200, :headers => headers, :body => body)
      end

      before :all do
        @query = Book.all(:author => 'Dan Kubb').query

        @response = @adapter.read(@query)
      end

      it 'should return an Array with the matching Records' do
        @response.should == [ { 'id' => 1, 'created_at' => DateTime.parse('2009-05-17T22:38:42-07:00'), 'title' => 'DataMapper', 'author' => 'Dan Kubb' } ]
      end
    end
  end

  describe '#update' do
    before :all do
      body = <<-XML.compress_lines
        <books>
          <book>
            <id type='datamapper::types::serial'>1</id>
            <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
            <title>DataMapper</title>
            <author>Dan Kubb</author>
          </book>
        </books>
      XML

      headers = { 'Content-Length' => body.respond_to?(:bytesize) ? body.bytesize : body.size }

      FakeWeb.register_uri(:get, 'http://admin:secret@localhost:4000/books.xml', :status => 200, :headers => headers, :body => body)
    end

    before :all do
      body = <<-XML.compress_lines
        <book>
          <id type='datamapper::types::serial'>1</id>
          <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
          <title>DataMapper</title>
          <author>John Doe</author>
        </book>
      XML

      headers = { 'Content-Length' => body.respond_to?(:bytesize) ? body.bytesize : body.size }

      FakeWeb.register_uri(:put, 'http://admin:secret@localhost:4000/books/1.xml', :status => 200, :headers => headers, :body => body)
    end

    before :all do
      @resources = Book.all

      @response = @adapter.update({ Book.properties[:author] => 'John Doe' }, @resources)
    end

    it 'should return the number of updated Resources' do
      @response.should == 1
    end

    it 'should modify the Resource' do
      @resources.first.author.should == 'John Doe'
    end
  end

  describe '#delete' do
    before :all do
      body = <<-XML.compress_lines
        <books>
          <book>
            <id type='datamapper::types::serial'>1</id>
            <created_at type='datetime'>2009-05-17T22:38:42-07:00</created_at>
            <title>DataMapper</title>
            <author>Dan Kubb</author>
          </book>
        </books>
      XML

      headers = { 'Content-Length' => body.respond_to?(:bytesize) ? body.bytesize : body.size }

      FakeWeb.register_uri(:get, 'http://admin:secret@localhost:4000/books.xml', :status => 200, :headers => headers, :body => body)
    end

    before :all do
      FakeWeb.register_uri(:delete, 'http://admin:secret@localhost:4000/books/1.xml', :status => 204)
    end

    before :all do
      @resources = Book.all

      @response = @adapter.delete(@resources)
    end

    it 'should return the number of updated Resources' do
      @response.should == 1
    end
  end
end
