require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-types'
    gem.summary     = 'DataMapper plugin providing extra data types'
    gem.description = gem.summary
    gem.email       = 'dan.kubb [a] gmail [d] com'
    gem.homepage    = 'http://github.com/datamapper/dm-more/tree/master/%s' % gem.name
    gem.authors     = [ 'Dan Kubb' ]

    gem.rubyforge_project = 'datamapper'

    gem.add_dependency 'bcrypt-ruby', '~> 2.1.2'
    gem.add_dependency 'dm-core',     '~> 0.10.2'
    gem.add_dependency 'fastercsv',   '~> 1.5.0'
    gem.add_dependency 'json_pure',   '~> 1.2.0'
    gem.add_dependency 'uuidtools',   '~> 2.1.1'
    gem.add_dependency 'stringex',    '~> 1.1.0'

    gem.add_development_dependency 'rspec', '~> 1.2.9'
    gem.add_development_dependency 'yard',  '~> 0.4.0'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
