
WORKSPACE_PATH="Example/RZVinylDemo.xcworkspace"
TEST_SCHEME="RZVinylDemo"

#
# Build
#

task :install do
  # don't care if this fails on travis
  sh("brew update") rescue nil
  sh("brew upgrade xctool") rescue nil
  sh("gem install cocoapods --no-rdoc --no-ri --no-document --quiet") rescue nil
end

task :test do
  sh("xctool -workspace '#{WORKSPACE_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator clean build test -freshInstall") rescue nil
  exit $?.exitstatus
end

task :clean do
  sh("rm -f Example/Podfile.lock")
  sh "rm -rf Example/Pods"
  sh("rm -rf Example/*.xcworkspace")
end

#
# Utils
#

task :usage do
  puts "Usage:"
  puts "  rake install      -- install build dependencies (xctool, cocoapods)"
  puts "  rake test         -- run unit tests"
  puts "  rake clean        -- clean up test cocoapods"
  puts "  rake sync         -- synchronize project/directory hierarchy"
  puts "  rake usage        -- print this message"
end

task :sync do
  sync_project(PROJ_PATH, '--exclusion /Classes')
end

#
# Default
#

task :default => 'usage'

#
# Private
#

private

def sync_project(path, flags)
  sh("synx #{flags} '#{path}'")
end