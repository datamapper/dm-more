module DataMapper
  # Set this to the version of dm-core that you are building against/for
  VERSION = "0.9.0"

  # Set this to the version of dm-more you plan to release
  MORE_VERSION = "0.9.0"
end

require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
include FileUtils

gems = %w[
  merb_datamapper
  dm-migrations
  dm-serializer
  dm-validations
]

PROJECT = "dm-more"

dm_more_spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY 
  s.name = PROJECT 
  s.summary = "An Object/Relational Mapper for Ruby"
  s.description = "Faster, Better, Simpler."
  s.version = DataMapper::MORE_VERSION
 
  s.authors = "Sam Smoot"
  s.email = "ssmoot@gmail.com"
  s.rubyforge_project = PROJECT 
  s.homepage = "http://datamapper.org" 
 
  s.files = %w[ MIT-LICENSE README Rakefile TODO ]
  s.add_dependency("dm-core", ">= #{DataMapper::VERSION}")
  gems.each do |gem|
    s.add_dependency gem, [">= #{DataMapper::VERSION}"]
  end
end

Rake::GemPackageTask.new(dm_more_spec) do |p|
  p.gem_spec = dm_more_spec
  p.need_tar = true
  p.need_zip = true
end

CLEAN.include ["**/.*.sw?", "pkg", "lib/*.bundle", "*.gem", "doc/rdoc", ".config", "coverage", "cache", "lib/merb-more.rb"]

windows = (PLATFORM =~ /win32|cygwin/) rescue nil

SUDO = windows ? "" : "sudo"

desc "Install it all"
task :install => [:install_gems, :package] do
  sh %{#{SUDO} gem install --local pkg/dm-more-#{DataMapper::MORE_VERSION}.gem  --no-update-sources}
  sh %{#{SUDO} gem install --local pkg/dm-#{DataMapper::MORE_VERSION}.gem --no-update-sources}
end

desc "Build the dm-more gems"
task :build_gems do
  gems.each do |dir|
    Dir.chdir(dir){ sh "rake gem" }
  end
end

desc "Install the dm-more gems"
task :install_gems => :build_gems do
  gems.each do |dir|
    Dir.chdir(dir){ sh "#{SUDO} rake install" }
  end
end

desc "Uninstall the dm-more gems"
task :uninstall_gems do
  gems.each do |sub_gem|
    sh %{#{SUDO} gem uninstall #{sub_gem}}
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
  cp "pkg/dm-#{DataMapper::MORE_VERSION}.gem", "bundle"
  cp "pkg/dm-more-#{DataMapper::MORE_VERSION}.gem", "bundle"
  gems.each do |gem|
    File.open("#{gem}/Rakefile") do |rakefile|
      rakefile.read.detect {|l| l =~ /^VERSION\s*=\s*"(.*)"$/ }
      sh %{cp #{gem}/pkg/#{gem}-#{$1}.gem bundle/}
    end
  end
end
