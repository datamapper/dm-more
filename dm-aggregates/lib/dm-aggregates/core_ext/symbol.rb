class Symbol
  [ :count, :min, :max, :avg, :sum ].each do |sym|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{sym}
        DataMapper::Query::Operator.new(self, #{sym.inspect})
      end
    RUBY
  end
end # class Symbol
