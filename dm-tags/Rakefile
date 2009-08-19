require 'pathname'
require 'rubygems'

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/dm-tags/version'

AUTHOR = 'Bobby Calderwood'
EMAIL  = 'bobby_calderwood [a] me [d] com'
GEM_NAME = 'dm-tags'
GEM_VERSION = DataMapper::Tags::VERSION
GEM_DEPENDENCIES = [['dm-core', GEM_VERSION], ['dm-validations', GEM_VERSION]]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.rdoc LICENSE TODO History.rdoc ] }

PROJECT_NAME = 'datamapper'
PROJECT_URL  = "http://github.com/datamapper/dm-more/tree/master/#{GEM_NAME}"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = "This package brings tagging to DataMapper.  It is inspired by Acts As Taggable On by Michael Bleigh, github's mbleigh.  Props to him for the contextual tagging based on Acts As Taggable on Steroids."

[ ROOT, ROOT.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
