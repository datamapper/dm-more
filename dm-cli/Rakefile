require 'rubygems'
require 'spec'
require 'spec/rake/spectask'
require 'rake/gempackagetask'
require 'pathname'

PLUGIN = "dm-cli"
NAME = "dm-cli"
VERSION = "0.9.0"
AUTHOR = "Wayne E. Seguin"
EMAIL = "wayneeseguin@gmail.com"
HOMEPAGE = "http://github.com/sam/dm-more/tree/master/dm-cli"
SUMMARY = "DataMapper plugin viewing your models using a cli interface"

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
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Pathname.glob(Pathname.new(__FILE__).parent.join("spec").join("**").join("*_spec.rb"))
end
