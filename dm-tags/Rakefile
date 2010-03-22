require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-tags'
    gem.summary     = "This package brings tagging to DataMapper.  It is inspired by Acts As Taggable On by Michael Bleigh, github's mbleigh.  Props to him for the contextual tagging based on Acts As Taggable on Steroids."
    gem.description = gem.summary
    gem.email       = 'bobby_calderwood [a] me [d] com'
    gem.homepage    = 'http://github.com/datamapper/dm-more/tree/master/%s' % gem.name
    gem.authors     = [ 'Bobby Calderwood' ]

    gem.rubyforge_project = 'datamapper'

    gem.add_dependency 'dm-core',                    '~> 0.10.3'

    gem.add_development_dependency 'rspec',          '~> 1.3'
    gem.add_development_dependency 'yard',           '~> 0.5'
    gem.add_development_dependency 'dm-validations', '~> 0.10.3'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
