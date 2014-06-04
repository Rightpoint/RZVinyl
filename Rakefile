
EXAMPLE_PATH="Example/RZVinylDemo.xcodeproj"
TESTS_PATH="" #TODO

namespace :example do
  
  task :sync do
    sync_project(EXAMPLE_PATH, '--exclusion External')
  end

end

namespace :tests do
  
  task :sync do
    sync_project
  end

end


task :usage do
  puts "Usage:"
  puts "  rake sync:(example|tests) -- synchronize project/directory hierarchy"
end

task :default => 'usage'

private

def sync_project(path, flags)
  sh("synx '#{flags}' '#{path}'")
end