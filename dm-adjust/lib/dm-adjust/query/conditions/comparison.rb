module DataMapper
  class Query
    module Conditions
      class AbstractOperation
        def each_node
          operands = self.operands.to_a

          while operand = operands.shift
            if operand.respond_to?(:operands)
              operands.concat(operand.operands)
            else
              yield operand
            end
          end
        end
      end

      class AbstractComparison
        # this is necessary to allow dm-adjust to change the conditions
        # of the query in an existing collection
        attr_accessor :value
      end
    end
  end
end
