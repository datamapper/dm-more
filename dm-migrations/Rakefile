require 'rubygems'
require 'spec'
require 'rake/clean'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'pathname'

CLEAN.include '{log,pkg}/'

spec = Gem::Specification.new do |s|
  s.name             = 'dm-migrations'
  s.version          = '0.9.1'
  s.platform         = Gem::Platform::RUBY
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README LICENSE TODO ]
  s.summary          = 'DataMapper plugin for writing and specing migrations'
  s.description      = s.summary
  s.author           = 'Paul Sadauskas'
  s.email            = 'psadauskas@gmail.com'
  s.homepage         = 'http://github.com/sam/dm-more/tree/master/dm-migrations'
  s.require_path     = 'lib'
  s.files            = FileList[ '{lib,spec}/**/*.rb', 'spec/spec.opts', 'Rakefile', *s.extra_rdoc_files ]
  s.add_dependency('dm-core', "=#{s.version}")
end

task :default => [ :spec ]

WIN32 = (RUBY_PLATFORM =~ /win32|mingw|cygwin/) rescue nil
SUDO  = WIN32 ? '' : ('sudo' unless ENV['SUDOLESS'])

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install #{spec.name} #{spec.version} (default ruby)"
task :install => [ :package ] do
  sh "#{SUDO} gem install pkg/#{spec.name}-#{spec.version} --no-update-sources", :verbose => false
end

namespace :jruby do
  desc "Install #{spec.name} #{spec.version} with JRuby"
  task :install => [ :package ] do
    sh %{#{SUDO} jruby -S gem install --local pkg/#{spec.name}-#{spec.version} --no-update-sources}, :verbose => false
  end
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts << '--options' << 'spec/spec.opts' if File.exists?('spec/spec.opts')
  t.spec_files = Pathname.glob(Pathname.new(__FILE__).dirname + 'spec/**/*_spec.rb')
end

namespace :db do

  # pass the relative path to the migrations directory by MIGRATION_DIR
  task :setup_migration_dir do
    unless defined?(MIGRATION_DIR)
      migration_dir = ENV["MIGRATION_DIR"] || File.join("db", "migrations")
      MIGRATION_DIR = File.expand_path(File.join(File.dirname(__FILE__), migration_dir))
    end
    FileUtils.mkdir_p MIGRATION_DIR
  end

  # set DIRECTION to migrate down
  desc "Run your system's migrations"
  task :migrate => [:setup_migration_dir] do
    require File.expand_path(File.join(File.dirname(__FILE__), "lib", "migration_runner.rb"))
    require File.expand_path(File.join(MIGRATION_DIR, "config.rb"))

    Dir[File.join(MIGRATION_DIR, "*.rb")].each { |file| require file }

    ENV["DIRECTION"] != "down" ? migrate_up! : migrate_down!
  end
end
