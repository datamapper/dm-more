require 'pathname'
require 'rubygems'

ROOT = Pathname(__FILE__).dirname.expand_path

require ROOT + 'lib/dm-cli/version'

AUTHOR = 'Wayne E. Seguin'
EMAIL  = 'wayneeseguin [a] gmail [d] com'
GEM_NAME = 'dm-cli'
GEM_VERSION = DataMapper::CLI::VERSION
GEM_DEPENDENCIES = [['dm-core', "~>#{GEM_VERSION}"]]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE TODO ],
               :executables => %w[ dm ], :bindir => 'bin' }

PROJECT_NAME = 'datamapper'
PROJECT_URL  = "http://github.com/sam/dm-more/tree/master/#{GEM_NAME}"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'DataMapper plugin allowing interaction with models through a CLI'

[ ROOT, ROOT.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
