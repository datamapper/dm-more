require File.join(File.dirname(__FILE__), *%w[.. helper])

Dir["#{File.dirname(__FILE__)}/*"].each do |file|
  unless (file =~ /\.rb$/)
    file_name = file.split('/').last
    begin
      require File.join(File.dirname(__FILE__), "..", "resources", "steps", file_name)
    rescue LoadError
      puts "Can't find #{file_name}.rb to define story steps; assuming this is intentional"
    rescue Exception => e
      puts e.backtrace
      exit 1
    end
    with_steps_for :using_rest_adapter, file_name.to_sym do
      run file if File.file?(file)
    end
  end
end
