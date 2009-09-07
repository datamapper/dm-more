require 'spec_helper'

describe SQL::Column do
  before do
    @column = SQL::Column.new
  end

  %w{name type not_null default_value primary_key unique}.each do |meth|
    it "should have a ##{meth} attribute" do
      @column.should respond_to(meth.intern)
    end
  end

end
