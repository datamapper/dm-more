# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      # If you think that this particular fixture class
      # and assumptions made below are full of bullshit
      # and author is a moron, you are 100% right. I am,
      # but it's me who rewrites poor dm-validations
      # spec suite this time, so unless someone smart
      # steps up to do it, we have to roll on with
      # this crappy example of method validation. — MK
      class ProgrammingLanguage
        #
        # Behaviors
        #

        include ::DataMapper::Validate

        #
        # Attributes
        #

        attr_accessor :name, :allows_system_calls, :allows_manual_memory_management, :allows_optional_parentheses,
          :allows_operator_overload, :approved_by_linus, :compiler_excels_at_utilizing_cpu_cache,
          :is_very_high_level, :does_not_require_explicit_return_keyword, :standard_library_support_parallel_programming_out_of_the_box

        #
        # Validations
        #

        validates_with_method :ensure_appropriate_for_system_programming,  :when => [:doing_system_programming, :hacking_on_the_kernel, :implementing_a_game_engine]
        validates_with_method :ensure_appropriate_for_dsls,                :when => [:implementing_a_dsl]
        validates_with_method :ensure_appropriate_for_cpu_intensive_tasks, :when => [:implementing_a_game_engine_core]
        validates_with_method :ensure_approved_by_linus_himself,           :when => [:hacking_on_the_kernel]

        #
        # API
        #

        def initialize(args = {})
          args.each do |key, value|
            self.send("#{key}=", value)
          end
        end

        def ensure_appropriate_for_system_programming
          if allows_manual_memory_management && allows_system_calls
            true
          else
            [false, "try something that is closer to the metal"]
          end
        end

        def ensure_appropriate_for_dsls
           if allows_optional_parentheses && allows_operator_overload && is_very_high_level && does_not_require_explicit_return_keyword
            true
          else
            [false, "may not be so good for domain specific languages"]
          end
        end

        def ensure_appropriate_for_cpu_intensive_tasks
          if compiler_excels_at_utilizing_cpu_cache && allows_manual_memory_management
            true
          else
            [false, "may not be so good for CPU intensive tasks"]
          end
        end

        def ensure_approved_by_linus_himself
          if name.downcase == "c++"
            [false, "Quite frankly, even if the choice of C were to do *nothing*
              but keep the C++ programmers out, that in itself would be
              a huge reason to use C."]
          else
            true
          end
        end
      end # ProgrammingLanguage
    end # Fixtures
  end # Validate
end # DataMapper
