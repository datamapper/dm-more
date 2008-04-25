require 'rubygems'
require 'spec'
require 'spec/rake/spectask'
require 'rake/gempackagetask'
require 'pathname'

PLUGIN = "dm-is-tree"
NAME = "dm-is-tree"
VERSION = "0.9.0"
AUTHOR = "Timothy Bennett"
EMAIL = "leapord729@comcast.net"
HOMEPAGE = "http://github.com/sam/dm-more/tree/master/dm-is-tree"
SUMMARY = "DataMapper plugin allowing the creation of tree structures from your models"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('dm-core', '>= 0.9.0')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs}/**/*")
end

task :default => :spec

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install #{NAME} #{VERSION}"
task :install => :package do
  sh %{sudo gem install pkg/#{NAME}-#{VERSION} --no-update-sources}
end

desc "Run specifications"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts << '--format' << 'specdoc' << '--colour'
  t.spec_files = Pathname.glob(Pathname.new(__FILE__).parent + 'spec/**/*_spec.rb')
end
