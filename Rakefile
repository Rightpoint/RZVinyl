
EXAMPLE_PATH="Example/RZVinylDemo.xcodeproj"
TESTS_PATH="" #TODO

namespace :example do
  
  task :sync do
    sync_project(EXAMPLE_PATH, '--exclusion /External')
  end

end

namespace :tests do
  
  task :sync do
    sync_project(TESTS_PATH, '')
  end

end

task :sync do
  Rake::Task['example:sync'].invoke
  Rake::Task['tests:sync'].invoke
end

task :usage do
  puts "Usage:"
  puts "  rake (example|tests):sync -- synchronize project/directory hierarchy"
end

task :default => 'usage'

private

def sync_project(path, flags)
  sh("synx #{flags} '#{path}'")
end