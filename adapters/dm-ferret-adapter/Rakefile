require 'pathname'

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/ferret_adapter/version'

AUTHOR = 'Bernerd Schaefer'
EMAIL  = 'bernerd [a] wieck [d] com'
GEM_NAME = 'dm-ferret-adapter'
GEM_VERSION = DataMapper::FerretAdapter::VERSION
GEM_DEPENDENCIES = [['dm-core', GEM_VERSION], ['ferret', '~>0.11.6']]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.rdoc LICENSE TODO History.rdoc ] } #,
#               :executables => %w[ ferret ], :bindir => 'bin' }  # FIXME: should this be enabled?

PROJECT_NAME = 'datamapper'
PROJECT_URL  = "http://github.com/sam/dm-more/tree/master/adapters/#{GEM_NAME}"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'Ferret Adapter for DataMapper'

[ ROOT, ROOT.parent.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
