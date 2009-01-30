= dm-tags

http://github.com/datamapper/dm-more/tree/master

== Description

This package brings tagging to DataMapper.  It is inspired by Acts As Taggable On by Michael Bleigh, github's mbleigh.  Props to him for the contextual tagging based on Acts As Taggable on Steroids.

== Features and Problems

=== Features

* Contextual tagging using Model.has_tags_on (see below for usage)
* Traditional 'tags-only' tagging using Model.has_tags

=== Problems

* None known yet, but this is very alpha software.  Sorry if it misbehaves.  Please send me a github message if you find a bug.

== Synopsis

  require 'rubygems'
  require 'dm-core'
  require 'dm-tags'

  DataMapper.setup(:default, "sqlite3::memory:")

  class MyModel
    include DataMapper::Resource
    property :id, Serial
    has_tags_on :tags, :skills
  end

  DataMapper.auto_migrate!

  # Contextual tagging
  MyModel.taggable? #=> true
  MyModel.new.taggable? #=> true

  model = MyModel.new
  model.tag_list = 'test, me out,   please   '
  model.tag_list #=> ['me out', 'please', 'test'] # Sanitized and alphabetized
  model.save #=> true
  model.tags
  #=> [#<Tag id=1 name="me out">, #<Tag id=2 name="please">, #<Tag id=3 name="test">]
  model.tag_list = 'test, again'
  model.save #=> true
  model.tags
  #=> [#<Tag id=3 name="test">, #<Tag id=4 name="again">] # Checks for existing tags
  Tag.all
  #=> [#<Tag id=1 name="me out">, #<Tag id=2 name="please">, #<Tag id=3 name="test">, #<Tag id=4 name="again">]
  another = MyModel.new
  another.skill_list = 'test, all, you, like'
  another.save #=> true
  another.tag_list #=> []
  another.skills
  #=> [#<Tag id=5 name="all">, #<Tag id=6 name="like">,  #<Tag id=3 name="test">, #<Tag id=7 name="you">]

  MyModel.tagged_with('test') #=> [#<MyModel id=1>, #<MyModel id=2>]
  MyModel.tagged_with('test', :on => 'tags') #=> [#<MyModel id=1>]
  MyModel.tagged_with('test', :on => 'skills') #=> [#<MyModel id=2>]


  #Helper methods for text fields
  model.tag_collection = "tag1, tag2, tag3"
  model.save
  model.tag_collection => "tag1, tag2, tag3"
  model.tags
  #=> [#<Tag id=1 name="tag1">, #<Tag id=2 name="tag2">, #<Tag id=3 name="tag3">]

  # Traditional 'tags only' tagging

  class TagsOnly
    include DataMapper::Resource
    property :id, Serial
    has_tags
  end

  TagsOnly.auto_migrate!

  TagsOnly.taggable? #=> true
  TagsOnly.new.taggable? #=> true

  tags_only = TagsOnly.new
  tags_only.tag_list = 'tags, only'
  tags_only.tag_list #=> ['only', 'tags']
  tags_only.save #=> true
  tags_only.tags #=> [#<Tag id=8 name="only">, #<Tag id=9 name="tags">]

== Requirements

* DataMapper (dm-core)

== Installation

  git clone http://github.com/datamapper/dm-more/tree/master
  cd dm-tags
  rake install

== License

(The MIT License)

Copyright (c) 2008 Bobby Calderwood

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
