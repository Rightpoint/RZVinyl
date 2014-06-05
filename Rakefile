PROJ_PATH="Example/RZVinylDemo.xcodeproj"

# task :test do
#   Rake::Task['tests:test'].invoke
# end

task :sync do
  sync_project(PROJ_PATH, '--exclusion /Classes')
end

task :usage do
  puts "Usage:"
  puts "  rake sync -- synchronize project/directory hierarchy"
end

task :default => 'usage'

private

def sync_project(path, flags)
  sh("synx #{flags} '#{path}'")
end