# An invalid example.
class InvalidTransitions1
  include DataMapper::Resource
  
  property :id, Serial

  is :state_machine do
    state :happy
    state :sad
    
    event :toggle
    
    # The next lines are intentionally incorrect.
    #
    # 'transitions' is only valid when nested beneath 'event'
    transitions :to => :happy, :from => :sad
    transitions :to => :sad,   :from => :happy
  end

end

InvalidTransitions1.auto_migrate!
