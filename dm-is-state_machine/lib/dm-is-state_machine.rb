require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-is-state_machine' / 'is'

require dir / 'state_machine'
require dir / 'data' / 'event'
require dir / 'data' / 'machine'
require dir / 'data' / 'state'
require dir / 'dsl' / 'event_dsl'
require dir / 'dsl' / 'state_dsl'

module DataMapper
  module Model
    include DataMapper::Is::StateMachine
  end # module Model
end # module DataMapper

# An alternative way to do the same thing as above:
# DataMapper::Model.append_extensions DataMapper::Is::StateMachine
