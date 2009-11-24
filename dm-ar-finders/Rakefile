require 'rubygems'
require 'rake'

FileList['tasks/**/*.rake'].each { |task| load task }

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-ar-finders'
    gem.summary     = 'DataMapper plugin providing ActiveRecord-style finders'
    gem.description = gem.summary
    gem.email       = 'john [a] wishVPS [d] com'
    gem.homepage    = 'http://github.com/datamapper/dm-more/tree/master/%s' % gem.name
    gem.authors     = [ 'John W Higgins' ]

    gem.rubyforge_project = 'datamapper'

    gem.add_dependency 'dm-core', '~>0.10.2'

    gem.add_development_dependency 'rspec', '>= 1.2.9'
    gem.add_development_dependency 'yard',  '>= 0.4.0'
  end

  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = 'yardoc'
  end
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
