Pod::Spec.new do |s|
  s.name                = "RZVinyl"
  s.version             = "1.0.2"
  s.summary             = "Stack management, ActiveRecord utilities, and seamless importing for Core Data."

  s.description         = <<-DESC
                          Stack management, ActiveRecord utilities, and seamless importing for Core Data.
                          RZVinyl makes it easy to manage Core Data stacks, multiple contexts, concurrency,
                          and more.
                          
                          ActiveRecord-style extensions for NSManagedObject let you easily create, find, filter,
                          sort, and enumerate objects in your database.
                          
                          With the RZImport extension, importing objects into Core Data from external sources
                          is simple and intuitive.
                          DESC

  s.homepage            = "https://github.com/Raizlabs/RZVinyl"
  s.license             = { :type => "MIT", :file => "LICENSE" }

  s.author              = { "Nick Donaldson" => "nick.donaldson@raizlabs.com" }
  s.social_media_url    = "http://twitter.com/raizlabs"

  s.platform            = :ios, "7.0"
  s.source              = { :git => "https://github.com/Raizlabs/RZVinyl.git", :tag => "1.0.2" }

  s.frameworks          = "Foundation", "CoreData"
  s.requires_arc        = true
  
  s.default_subspec     = 'Extensions'
  
  s.subspec "Core" do |sp|
    sp.source_files         = "Classes/*.{h,m}", "Classes/Private/*.{h,m}"
    sp.public_header_files  = "Classes/*.h"
    sp.private_header_files = "Classes/Private/*.h"
  end
  
  s.subspec "Extensions" do |sp|
    sp.dependency 'RZVinyl/Core'
    sp.source_files = "Extensions/*.{h,m}", "Extensions/Private/*.{h,m}"
    sp.public_header_files = "Extensions/*.h"
    sp.private_header_files = "Extensions/Private/*.h"
    sp.xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => 'RZV_IMPORT_AVAILABLE=1'}
    sp.dependency 'RZImport', '~> 1.0'
  end
    
end
 