desc 'Run all stories'
task :stories do
  # TODO Re-migrate the book service or else you won't have test data!
  ruby 'stories/all.rb --colour --format plain'
end
