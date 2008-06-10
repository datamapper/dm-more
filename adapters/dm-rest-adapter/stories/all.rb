require File.join(File.dirname(__FILE__), *%w[helper])

%w[crud].each do |dir|
  require File.join(File.dirname(__FILE__), "#{dir}/stories")
end
