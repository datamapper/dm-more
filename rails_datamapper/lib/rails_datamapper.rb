require 'pathname'
require 'dm-core'
require 'dm-aggregates'
require 'dm-migrations'
require 'dm-serializer'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-types'

dir = Pathname(__FILE__).dirname.expand_path / 'rails_datamapper'

require dir / 'rails_datamapper'
require dir / 'validations'
require dir / 'session_store'

create_connection()
