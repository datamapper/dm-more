require 'pathname'

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/dm-sweatshop/version'

AUTHOR = 'Ben Burkert'
EMAIL  = 'ben [a] benburkert [d] com'
GEM_NAME = 'dm-sweatshop'
GEM_VERSION = DataMapper::Sweatshop::VERSION
GEM_DEPENDENCIES = [['dm-core', GEM_VERSION], ['randexp', '~>0.1.4']]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.rdoc LICENSE TODO History.rdoc ] }

PROJECT_NAME = 'datamapper'
PROJECT_URL  = "http://github.com/datamapper/dm-more/tree/master/#{GEM_NAME}"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'DataMapper plugin for building pseudo random models'

[ ROOT, ROOT.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
