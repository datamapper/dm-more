require 'rubygems'
require 'spec'
require 'spec/rake/spectask'
require 'pathname'

ROOT = Pathname(__FILE__).dirname.expand_path
require ROOT + 'lib/dm-constraints/version'

AUTHOR = "Dirkjan Bussink"
EMAIL  = "d.bussink@gmail.com"
GEM_NAME = "dm-constraints"
GEM_VERSION = DataMapper::Constraints::VERSION
GEM_DEPENDENCIES = [["dm-core", GEM_VERSION]]
GEM_CLEAN = ["log", "pkg", "coverage"]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE TODO ] }

PROJECT_NAME = "datamapper"
PROJECT_URL  = "http://github.com/sam/dm-more/tree/master/dm-constraints"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = "DataMapper plugin for performing validations on data models"

require ROOT + 'tasks/hoe'
require ROOT + 'tasks/gemspec'
require ROOT + 'tasks/install'
require ROOT + 'tasks/dm'
require ROOT + 'tasks/doc'
require ROOT + 'tasks/ci'
