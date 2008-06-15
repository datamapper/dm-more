require 'rubygems'
require 'spec'
require 'rake/clean'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'pathname'

CLEAN.include '{log,pkg}/'

spec = Gem::Specification.new do |s|
  s.name             = 'dm-rest-adapter'
  s.version          = '0.9.2'
  s.platform         = Gem::Platform::RUBY
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README LICENSE TODO ]
  s.summary          = 'REST Adapter for DataMapper'
  s.description      = s.summary
  s.author           = 'Potomac Ruby Hackers'
  s.email            = 'potomac-ruby-hackers@googlegroups.com'
  s.homepage         = 'http://github.com/pjb3/dm-more/tree/master/adapters/dm-rest-adapter'
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

desc "Install #{spec.name} #{spec.version}"
task :install => [ :package ] do
  sh "#{SUDO} gem install pkg/#{spec.name}-#{spec.version} --no-update-sources", :verbose => false
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  if File.exists?('spec/spec.opts')
    t.spec_opts << '--options' << 'spec/spec.opts'
  end
  t.spec_files =
    Pathname.glob(Pathname.new(__FILE__).dirname + 'spec/**/*_spec.rb')
end

desc "Run all stories"
task :stories do
  ruby "stories/all.rb --colour --format plain"
end