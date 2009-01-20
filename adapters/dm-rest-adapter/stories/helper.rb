require 'pathname'
require 'rubygems'
require 'tempfile'

gem 'dm-core', '~>0.9.11'
require 'dm-core'

gem 'rspec', '~>1.1.11'
require 'spec'

ROOT = Pathname(__FILE__).dirname.parent.expand_path

# use local dm-serializer if running from dm-more directly
lib = ROOT.parent.parent.join('dm-serializer', 'lib').expand_path
$LOAD_PATH.unshift(lib) if lib.directory?

require ROOT + 'lib/rest_adapter'
require ROOT + 'stories/resources/helpers/story_helper'
require ROOT + 'stories/resources/steps/using_rest_adapter'
