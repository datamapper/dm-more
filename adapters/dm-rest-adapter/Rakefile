require 'rubygems'
require 'spec'
require 'spec/rake/spectask'
require 'pathname'

ROOT = Pathname(__FILE__).dirname.expand_path
require ROOT + 'lib/rest_adapter/version'

AUTHOR = "Potomac Ruby Hackers"
EMAIL  = "potomac-ruby-hackers@googlegroups.com"
GEM_NAME = "dm-rest-adapter"
GEM_VERSION = DataMapper::More::RestAdapter::VERSION
GEM_DEPENDENCIES = [['dm-core', "~>#{GEM_VERSION}"]]
GEM_CLEAN = ["log", "pkg"]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE TODO ] }

PROJECT_NAME = "datamapper"
PROJECT_URL  = "http://github.com/pjb3/dm-more/tree/master/adapters/dm-rest-adapter"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = "REST Adapter for DataMapper"

require ROOT.parent.parent + 'tasks/hoe'

task :default => [ :spec ]

WIN32 = (RUBY_PLATFORM =~ /win32|mingw|cygwin/) rescue nil
SUDO  = WIN32 ? '' : ('sudo' unless ENV['SUDOLESS'])

desc "Install #{GEM_NAME} #{GEM_VERSION}"
task :install => [ :package ] do
  sh "#{SUDO} gem install pkg/#{GEM_NAME}-#{GEM_VERSION} --no-update-sources", :verbose => false
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  if File.exists?('spec/spec.opts')
    t.spec_opts << '--options' << 'spec/spec.opts'
  end
  t.spec_files = Pathname.glob((ROOT + 'spec/**/*_spec.rb').to_s)
end

desc "Run all stories"
task :stories do
  # TODO Re-migrate the book service or else you won't have test data!
  ruby "stories/all.rb --colour --format plain"
end
