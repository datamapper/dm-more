require 'dm-core'
require 'dm-adjust'
require 'dm-transactions'

require 'dm-is-list/is/list'

DataMapper::Model.append_extensions DataMapper::Is::List
