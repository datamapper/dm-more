require 'dm-is-state_machine/is/state_machine'
require 'dm-is-state_machine/is/data/event'
require 'dm-is-state_machine/is/data/machine'
require 'dm-is-state_machine/is/data/state'
require 'dm-is-state_machine/is/dsl/event_dsl'
require 'dm-is-state_machine/is/dsl/state_dsl'

DataMapper::Model.append_extensions DataMapper::Is::StateMachine
