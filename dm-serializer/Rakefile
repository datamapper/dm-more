require 'rubygems'
require 'rake/gempackagetask'

PLUGIN = "dm-serializer"
NAME = "dm-serializer"
VERSION = "0.9.0"
AUTHOR = "Guy van den Berg"
EMAIL = "vandenberg.guy@gmail.com"
HOMEPAGE = "http://github.com/sam/dm-more/tree/master/dm-serializer"
SUMMARY = "DataMapper plugin for serializing DataMapper objects"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
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

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{NAME}-#{VERSION} --no-update-sources}
end

