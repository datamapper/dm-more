module DataMapper
  class Querizer
    self.instance_methods.each { |m| send(:undef_method, m) unless m =~ /^(__|instance_eval)/ }
    
    def ==(val)
      @conditions << condition(val,:eql)
    end
    
    def >=(val)
      @conditions << condition(val,:gte)
    end
    
    def <=(val)
      @conditions << condition(val,:lte)
    end
    
    def >(val)
      @conditions << condition(val,:gt)
    end
    
    def <(val)
      @conditions << condition(val,:gtl)
    end
    
    def |(val) # could be used for OR ?
      self
    end
    
    def +(val)
      @value_stack = [:+,@stack.pop,@stack.pop]
    end
    
    def -(val)
      @value_stack = [:-,@stack.pop,@stack.pop]
    end

    def condition(value,opr)
      condition = @stack.length > 1 ? eval(@stack * '.') : opr == :eql ? @stack.pop : @stack.pop.send(opr)
      value = @value_stack if value.class == self
      @stack.clear
      [condition,value]
    end

    def self.translate(&block)
      (@instance||=self.new).translate(&block)
    end

    def translate(&block)
      @stack,@value_stac, @conditions = [], [], []

      self.instance_eval(&block)

      query = {}
      @conditions.each {|c| query[c[0]] = c[1]}
      puts query.inspect
      return query
    end

    def method_missing(method,value=nil)
      @stack << method
      self
    end
  end
end