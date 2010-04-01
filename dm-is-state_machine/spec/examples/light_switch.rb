class LightSwitch
  include DataMapper::Resource
  property :id,   Serial
  property :type, Discriminator

  is :state_machine, :initial => :off do
    state :off
    state :on, :enter => :on_hook

    event :switch do
      transition :from => :on, :to => :off
      transition :from => :off, :to => :on
    end
  end

  def on_hook
    puts "Light turned on!"
  end
end

class Dimmer < LightSwitch
  def on_hook
    puts "Lights! Camera! Action! your're on!"
  end
end
