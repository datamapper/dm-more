module DataMapper
  module Is
    module StateMachine
      module Data
    
        # Represents one state machine
        class Machine

          attr_reader :column, :initial
          attr_accessor :current_state_name
          attr_accessor :events, :states
          
          def initialize(column, initial)
            @column, @initial   = column, initial
            @events, @states    = [], []
            @current_state_name = initial
          end
          
          # Fire (activate) the event with name +event_name+
          #
          # @api public
          def fire_event(event_name, resource)
            unless event = find_event(event_name)
              raise InvalidEvent, "Could not find event (#{event_name.inspect})"
            end
            transition = event.transitions.find do |t|
               t[:from].to_s == @current_state_name.to_s
            end
            unless transition
              raise InvalidEvent, "Event (#{event_name.inspect}) does " +
              "not exist for current state (#{@current_state_name.inspect})"
            end
            @current_state_name = transition[:to]

            # ===== Call :enter Proc if present =====
            return unless enter_proc = current_state.options[:enter]
            enter_proc.call(resource)
          end

          # Return the current state
          #
          # @api public
          def current_state
            find_state(@current_state_name)
            # TODO: add caching, i.e. with `@current_state ||= ...`
          end
          
          # Find event whose name is +event_name+
          #
          # @api semipublic
          def find_event(event_name)
            @events.find { |event| event.name.to_s == event_name.to_s }
            # TODO: use a data structure that prevents duplicates
          end
          
          # Find state whose name is +event_name+
          #
          # @api semipublic
          def find_state(state_name)
            @states.find { |state| state.name.to_s == state_name.to_s }
            # TODO: use a data structure that prevents duplicates
          end
          
        end
        
      end # Data
    end # StateMachine
  end # Is
end # DataMapper
