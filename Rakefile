require 'pathname'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'fileutils'
require 'lib/dm-more/version.rb'
include FileUtils

## ORDER IS IMPORTANT
# gems may depend on other member gems of dm-more
gem_paths = %w[
  dm-adjust
  dm-serializer
  dm-validations
  dm-types
  adapters/dm-couchdb-adapter
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
  dm-querizer
  dm-shorthand
  dm-sweatshop
  dm-tags
  dm-timestamps
]

gems = gem_paths.map { |p| File.basename(p) }

ROOT = Pathname(__FILE__).dirname.expand_path

AUTHOR = "Sam Smoot"
EMAIL  = "ssmoot@gmail.com"
GEM_NAME = "dm-more"
GEM_VERSION = DataMapper::More::VERSION
GEM_DEPENDENCIES = [['dm-core', "~>#{GEM_VERSION}"], *gems.map { |g| [g, "~>#{GEM_VERSION}"] }]
GEM_CLEAN = ['**/.DS_Store}', '*.db', "doc/rdoc", ".config", "**/{coverage,log,pkg}", "cache", "lib/merb-more.rb"]
GEM_EXTRAS = { :has_rdoc => false }

PROJECT_NAME = "datamapper"
PROJECT_URL  = "http://datamapper.org"
PROJECT_DESCRIPTION = "Faster, Better, Simpler."
PROJECT_SUMMARY = "An Object/Relational Mapper for Ruby"

require ROOT + 'tasks/hoe'

WIN32 = (RUBY_PLATFORM =~ /win32|mingw|cygwin/) rescue nil
SUDO  = WIN32 ? '' : ('sudo' unless ENV['SUDOLESS'])

desc "Install it all"
task :install => [:install_gems, :package] do
  sh %{#{SUDO} gem install --local pkg/dm-more-#{DataMapper::More::VERSION}.gem  --no-update-sources}
end

desc "Uninstall it all"
task :uninstall => [ :uninstall_gems, :clobber ] do
  sh "#{SUDO} gem uninstall dm-more -v#{DataMapper::More::VERSION} -I -x", :verbose => false rescue "dm-more not installed"
end

desc "Build the dm-more gems"
task :build_gems do
  gem_paths.each do |dir|
    Dir.chdir(dir){ sh "rake gem" }
  end
end

desc "Install the dm-more gems"
task :install_gems => :build_gems do
  gem_paths.each do |dir|
    Dir.chdir(dir){ sh "rake install" }
  end
end

desc "Uninstall the dm-more gems"
task :uninstall_gems do
  gems.each do |sub_gem|
    sh %{#{SUDO} gem uninstall #{sub_gem} -I -x} rescue "#{sub_gem} not installed."
  end
end

task :package => ["lib/dm-more.rb"]
desc "Create dm-more.rb"
task "lib/dm-more.rb" do
  mkdir_p "lib"
  File.open("lib/dm-more.rb","w+") do |file|
    file.puts "### AUTOMATICALLY GENERATED.  DO NOT EDIT."
    gems.each do |gem|
      next if gem == "dm-gen"
      file.puts "require '#{gem}'"
    end
  end
end

desc "Bundle up all the dm-more gems"
task :bundle => [:package, :build_gems] do
  mkdir_p "bundle"
  cp "pkg/dm-more-#{DataMapper::More::VERSION}.gem", "bundle"
  gem_paths.each do |gem|
    File.open("#{gem}/Rakefile") do |rakefile|
      rakefile.read.detect {|l| l =~ /^VERSION\s*=\s*"(.*)"$/ }
      sh %{cp #{gem}/pkg/#{File.basename(gem)}-#{$1}.gem bundle/}
    end
  end
end

desc "Release all dm-more gems"
task :release_all do
  sh "rake release VERSION=#{DataMapper::More::VERSION}; true"
  gem_paths.each do |dir|
    Dir.chdir(dir) { sh "rake release VERSION=#{DataMapper::More::VERSION}; true" }
  end
end

%w[ ci spec clean clobber check_manifest ].each do |command|
  task command do
    gem_paths.each do |gem_name|
      Dir.chdir(gem_name){ sh("rake #{command}") }
    end
  end
end

namespace :dm do
  desc 'Run specifications'
  task :specs do
    Spec::Rake::SpecTask.new(:spec) do |t|
      Dir["**/Rakefile"].each do |rakefile|
        # don't run in the top level dir or in the pkg dir
        unless rakefile == "Rakefile" || rakefile =~ /^pkg/
          # running chdir in a block runs the task in specified dir, then returns to previous dir.
          Dir.chdir(File.join(File.dirname(__FILE__), File.dirname(rakefile))) do
            raise "Broken specs in #{rakefile}" unless system 'rake'
          end
        end
      end
    end
  end
end

task :default => :spec
