# A valid example of a resource with a state machine.
class TrafficLight
  include DataMapper::Resource

  property :id, Serial # see note 1

  is :state_machine, :initial => :green, :column => :color do
    state :green,  :enter => Proc.new { |o| o.log << "G" }
    state :yellow, :enter => Proc.new { |o| o.log << "Y" }
    state :red,    :enter => Proc.new { |o| o.log << "R" }

    event :forward do
      transitions :from => :green,  :to => :yellow
      transitions :from => :yellow, :to => :red
      transitions :from => :red,    :to => :green
    end

    event :backward do
      transitions :from => :green,  :to => :red
      transitions :from => :yellow, :to => :green
      transitions :from => :red,    :to => :yellow
    end
  end

  def log;     @log ||= [] end

  attr_reader :init
  def initialize(*args)
    (@init ||= []) << :init
    super
  end

end

TrafficLight.auto_migrate!

# ===== Note 1 =====
#
# One would expect that these two would be the same:
#   property :id, Serial
#   property :id, Integer, :serial => true
#
# But on 2008-07-05, the 2nd led to problems with an in-memory SQLite
# database.
