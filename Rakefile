require 'pathname'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'fileutils'
require 'lib/dm-more/version.rb'
include FileUtils

## ORDER IS IMPORTANT
# gems may depend on other member gems of dm-more
gem_paths = %w[
  adapters/dm-couchdb-adapter
  adapters/dm-rest-adapter
  dm-adjust
  dm-aggregates
  dm-ar-finders
  dm-cli
  dm-constraints
  dm-is-list
  dm-is-nested_set
  dm-is-state_machine
  dm-is-tree
  dm-migrations
  dm-observer
  dm-querizer
  dm-serializer
  dm-shorthand
  dm-sweatshop
  dm-timestamps
  dm-sweatshop
  dm-types
  dm-validations
  merb_datamapper
]

gems = gem_paths.map { |p| File.basename(p) }

ROOT = Pathname(__FILE__).dirname.expand_path

AUTHOR = "Sam Smoot"
EMAIL  = "ssmoot@gmail.com"
GEM_NAME = "dm-more"
GEM_VERSION = DataMapper::More::VERSION
GEM_DEPENDENCIES = [["dm-core", GEM_VERSION], *(gems - %w[ merb_datamapper ]).collect { |g| [g, GEM_VERSION] }]
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

namespace :ci do

  gems.each do |gem_name|
    task gem_name do
      ENV['gem_name'] = gem_name

      Rake::Task["ci:run_all"].invoke
    end
  end

  task :run_all => [:spec, :install, :doc, :publish]

  task :spec_all => :define_tasks do
    gems.each do |gem_name|
      Rake::Task["#{gem_name}:spec"].invoke
    end
  end

  task :spec => :define_tasks do
    Rake::Task["#{ENV['gem_name']}:spec"].invoke
  end

  task :doc => :define_tasks do
    Rake::Task["#{ENV['gem_name']}:doc"].invoke
  end

  task :install do
    sh %{cd #{ENV['gem_name']} && rake install}
  end

  task :publish do
    out = ENV['CC_BUILD_ARTIFACTS'] || "out"
    mkdir_p out unless File.directory? out if out

    mv "rdoc", "#{out}/rdoc" if out
    mv "coverage", "#{out}/coverage_report" if out && File.exists?("coverage")
    mv "rspec_report.html", "#{out}/rspec_report.html" if out && File.exists?("rspec_report.html")
  end

  task :define_tasks do
    gem_names = [(ENV['gem_name'] || gems)].flatten
    gem_names.each do |gem_name|
      Spec::Rake::SpecTask.new("#{gem_name}:spec") do |t|
        t.spec_opts = ["--format", "specdoc", "--format", "html:rspec_report.html", "--diff"]
        t.spec_files = Pathname.glob(ENV['FILES'] || (ROOT + "#{gem_name}/spec/**/*_spec.rb").to_s)
        unless ENV['NO_RCOV']
          t.rcov = true
          t.rcov_opts << '--exclude' << "spec,gems,#{(gems - [gem_name]).join(',')}"
          t.rcov_opts << '--text-summary'
          t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
          t.rcov_opts << '--only-uncovered'
        end
      end

      Rake::RDocTask.new("#{gem_name}:doc") do |t|
        t.rdoc_dir = 'rdoc'
        t.title    = gem_name
        t.options  = ['--line-numbers', '--inline-source', '--all']
        t.rdoc_files.include("#{gem_name}/lib/**/*.rb", "#{gem_name}/ext/**/*.c")
      end
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
