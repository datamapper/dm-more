require 'rubygems'
require 'spec'
require 'rake/clean'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'pathname'

CLEAN.include '{log,pkg}/'

spec = Gem::Specification.new do |s|
  s.name             = 'dm-ar-finders'
  s.version          = '0.9.0'
  s.platform         = Gem::Platform::RUBY
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README LICENSE TODO ]
  s.summary          = 'DataMapper plugin providing ActiveRecord-style finders'
  s.description      = s.summary
  s.author           = 'John W Higgins'
  s.email            = 'john@wishVPS.com'
  s.homepage         = 'http://github.com/sam/dm-more/tree/master/dm-ar-finders'
  s.require_path     = 'lib'
  s.files            = FileList[ '{lib,spec}/**/*.rb', 'spec/spec.opts', 'Rakefile', *s.extra_rdoc_files ]
  s.add_dependency('dm-core', '>= 0.9.0')
end

task :default => [ :spec ]

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install #{spec.name} #{spec.version}"
task :install => [ :package ] do
  sh "#{'sudo' unless ENV['SUDOLESS']} gem install pkg/#{spec.name}-#{spec.version}", :verbose => false
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts << '--options' << 'spec/spec.opts' if File.exists?('spec/spec.opts')
  t.spec_files = Pathname.glob(Pathname.new(__FILE__).dirname + 'spec/**/*_spec.rb')
end
