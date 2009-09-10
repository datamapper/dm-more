require 'pathname'

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/rails_datamapper/version'

AUTHOR = 'Tom Malone'
EMAIL  = 'tomjmalone [a] gmail [d] com'
GEM_NAME = 'rails_datamapper'
GEM_VERSION = Rails::DataMapper::VERSION
GEM_DEPENDENCIES = [['dm-core', GEM_VERSION]]
GEM_CLEAN = %w[ pkg ]
GEM_EXTRAS = { :has_rdoc => false, :extra_rdoc_files => %w[ README.rdoc LICENSE TODO History.rdoc ] }

PROJECT_NAME = 'datamapper'
PROJECT_URL  = "http://github.com/datamapper/dm-more/tree/master/#{GEM_NAME}"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'Rails Plugin for datamapper'

[ ROOT, ROOT.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).sort.each { |filename| require filename }
end
