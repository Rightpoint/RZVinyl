PROJ_PATH="Example/RZVinylDemo.xcodeproj"
TEST_SCHEME="RZVinylDemo"

# task :test do
#   Rake::Task['tests:test'].invoke
# end

task :prepare do
  sh("brew update") rescue nil
  exit $?.exitstatus unless $?.success?
  sh("brew upgrade xctool") rescue nil # don't care if this fails on travis
end

task :sync do
  sync_project(PROJ_PATH, '--exclusion /Classes')
end

task :test do
  sh("xctool -project '#{PROJ_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator clean build test -freshSimulator") rescue nil
  exit $?.exitstatus
end

task :usage do
  puts "Usage:"
  puts "  rake sync -- synchronize project/directory hierarchy"
  puts "  rake test -- run unit tests"
end

task :default => 'usage'

private

def sync_project(path, flags)
  sh("synx #{flags} '#{path}'")
end