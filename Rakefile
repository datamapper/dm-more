require 'pathname'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'fileutils'
include FileUtils

JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform? || (JRUBY && ENV_JAVA['os.name'] =~ /windows/i)

## ORDER IS IMPORTANT
# gems may depend on other member gems of dm-more
gem_paths = %w[
  dm-adjust
  dm-serializer
  dm-validations
  dm-types
  adapters/dm-ferret-adapter
  adapters/dm-rest-adapter
  dm-aggregates
  dm-ar-finders
  dm-cli
  dm-constraints
  dm-is-list
  dm-is-nested_set
  dm-is-remixable
  dm-is-searchable
  dm-is-state_machine
  dm-is-tree
  dm-is-versioned
  dm-migrations
  dm-observer
  dm-sweatshop
  dm-tags
  dm-timestamps
  rails_datamapper
]

# skip installing ferret on Ruby 1.9 until the gem is fixed
if JRUBY || WINDOWS || RUBY_VERSION < '1.9'
  gem_paths -= %w[ adapters/dm-ferret-adapter ]
end

gems = gem_paths.map { |gem_path| File.basename(gem_path) }

excluded_gems = ENV['EXCLUDE'] ? ENV['EXCLUDE'].split(',') : []
gem_paths     = gem_paths - excluded_gems

gem_spec = Gem::Specification.new do |gem|
  gem.name        = 'dm-more'
  gem.summary     = 'DataMapper Plugins'
  gem.description = gem.summary
  gem.email       = 'dan.kubb [a] gmail [d] com'
  gem.homepage    = 'http://github.com/datamapper/dm-more/'
  gem.authors     = [ 'Dan Kubb' ]

  gem.version = File.read('VERSION').chomp

  gem.rubyforge_project = 'datamapper'

  gem.add_dependency 'dm-core', '~> 0.10.3'

  gems.each do |gem_name|
    gem.add_dependency File.basename(gem_name), '~> 0.10.3'
  end

  gem.add_development_dependency 'rspec', '~> 1.3'
  gem.add_development_dependency 'yard',  '~> 0.5'

  gem.require_path = 'lib'
  gem.files        = %w[ LICENSE README.rdoc lib/dm-more.rb ]
end

Rake::GemPackageTask.new(gem_spec) do |package|
  package.gem_spec = gem_spec
end

FileList['tasks/**/*.rake'].each { |task| import task }

def rake(cmd, bundle_exec = false)
  sh "#{bundle_exec ? 'bundle exec ' : ''}#{RUBY} -S rake #{cmd}", :verbose => true
end

def bundle(cmd)
  sh "bundle #{cmd}", :verbose => true
end

desc "Install #{gem_spec.name}"
task :install do
  gem_paths.each do |dir|
    Dir.chdir(dir) { rake 'install', true }
  end
end

desc "Generate gemspecs for all gems in #{gem_spec.name}"
task :gemspec do
  gem_paths.each do |dir|
    Dir.chdir(dir) { rake 'gemspec', true }
  end
end

namespace :bundle do
  desc "Runs 'bundle install --without quality' for all gems in #{gem_spec.name} (suitable for spec runs)"
  task :install do
    gem_paths.each do |dir|
      Dir.chdir(dir) { bundle 'install --without quality' }
    end
  end

  namespace :install do
    desc "Runs 'bundle install' for all gems in #{gem_spec.name}"
    task :quality do
      gem_paths.each do |dir|
        Dir.chdir(dir) { bundle 'install' }
      end
    end
  end
end

file 'lib/dm-more.rb' do
  mkdir_p 'lib'
  File.open('lib/dm-more.rb', 'w+') do |file|
    file.puts '### AUTOMATICALLY GENERATED.  DO NOT EDIT.'
    gems.each do |gem|
      lib = if '-adapter' == gem[-8..-1]
        gem.split('-')[1..-1].join('_')
      else
        gem
      end
      file.puts "require '#{lib}'"
    end
  end
end

desc "Release #{gem_spec.name}"
task :release => [ :gem ] do
  gem_paths.each do |dir|
    Dir.chdir(dir) { rake 'release', true }

    # workaround Jeweler bug.  it was identifying the repo as
    # in a dirty state, but it is not.  running git status clears
    # the dirty state.
    system 'git status >/dev/null'
  end

  sh "#{RUBY} -S gem push pkg/dm-more-#{gem_spec.version}.gem"
end

desc 'Run specs'
task :spec do
  exit 1 unless (gem_paths - %w[ rails_datamapper ]).map do |gem_name|
    Dir.chdir(gem_name) { rake 'spec', true }
  end.all?
end

task :default => :spec
