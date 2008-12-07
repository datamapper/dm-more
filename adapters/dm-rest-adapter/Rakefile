require 'pathname'
require 'rubygems'

ROOT = Pathname(__FILE__).dirname.expand_path

require ROOT + 'lib/rest_adapter/version'

AUTHOR = 'Potomac Ruby Hackers'
EMAIL  = 'potomac-ruby-hackers [a] googlegroups [d] com'
GEM_NAME = 'dm-rest-adapter'
GEM_VERSION = DataMapper::RestAdapter::VERSION
GEM_DEPENDENCIES = [['dm-core', "~>#{GEM_VERSION}"]]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE TODO ] }

PROJECT_NAME = 'datamapper'
PROJECT_URL  = "http://github.com/sam/dm-more/tree/master/adapters/#{GEM_NAME}"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'REST Adapter for DataMapper'

[ ROOT, ROOT.parent.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
