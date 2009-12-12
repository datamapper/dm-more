require 'pathname'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'fileutils'
include FileUtils

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform? || (JRUBY && ENV_JAVA['os.name'] =~ /windows/i)
SUDO    = WINDOWS ? '' : ('sudo' unless ENV['SUDOLESS'])

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
if RUBY_VERSION >= '1.9.0' || JRUBY || WINDOWS
  gem_paths -= %w[ adapters/dm-ferret-adapter ]
end

GEM_PATHS = gem_paths.freeze

gems = GEM_PATHS.map { |p| File.basename(p) }

AUTHOR = 'Dan Kubb'
EMAIL  = 'dan.kubb [a] gmail [d] com'
GEM_NAME = 'dm-more'
GEM_VERSION = ROOT.join('VERSION').read
GEM_DEPENDENCIES = [['dm-core', GEM_VERSION], *gems.map { |g| [g, GEM_VERSION] }]
GEM_CLEAN = %w[ **/.DS_Store} *.db doc/rdoc .config **/{coverage,log,pkg} cache lib/dm-more.rb ]
GEM_EXTRAS = { :has_rdoc => false }

PROJECT_NAME = 'datamapper'
PROJECT_URL  = 'http://github.com/datamapper/dm-more/tree/master'
PROJECT_DESCRIPTION = 'Faster, Better, Simpler.'
PROJECT_SUMMARY = 'An Object/Relational Mapper for Ruby'

Pathname.glob(ROOT.join('tasks/**/*.rb').to_s).each { |f| require f }

desc "Install #{GEM_NAME} #{GEM_VERSION}"
task :install do
  GEM_PATHS.each do |dir|
    Dir.chdir(dir){ rake 'install' }
  end
end

def rake(cmd)
  sh "#{RUBY} -S rake #{cmd}", :verbose => true
end

task :package do
  mkdir_p 'lib'
  File.open('lib/dm-more.rb', 'w+') do |file|
    file.puts '### AUTOMATICALLY GENERATED.  DO NOT EDIT.'
    (gems - %w[ dm-gen ]).each do |gem|
      lib = if '-adapter' == gem[-8..-1]
        gem.split('-')[1..-1].join('_')
      else
        gem
      end
      file.puts "require '#{lib}'"
    end
  end
end

task :bundle => [ :package ] do
  mkdir_p 'bundle'
  cp "pkg/dm-more-#{GEM_VERSION}.gem", 'bundle'
  GEM_PATHS.each do |gem|
    File.open("#{gem}/Rakefile") do |rakefile|
      rakefile.read.detect {|l| l =~ /^VERSION\s*=\s*'(.*)'$/ }
      cp "#{gem}/pkg/#{File.basename(gem)}-#{$1}.gem", 'bundle'
    end
  end
end

# NOTE: this task must be named release_all, and not release
desc "Release #{GEM_NAME} #{GEM_VERSION}"
task :release_all do
  sh 'rake release'
  GEM_PATHS.each do |dir|
    Dir.chdir(dir) { rake 'release' }
  end
end

desc 'Run specs'
task :spec do
  exit 1 unless (GEM_PATHS - %w[ rails_datamapper ]).map do |gem_name|
    Dir.chdir(gem_name) { rake 'spec' }
  end.all?
end

task :default => :spec
