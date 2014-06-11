Pod::Spec.new do |s|
  s.name                = "RZVinyl"
  s.version             = "0.1.0"
  s.summary             = "Stack management, ActiveRecord utilities, and seamless importing for CoreData."

  s.description         = <<-DESC
                         Stack management, ActiveRecord utilities, and seamless importing for CoreData
                        DESC

  s.homepage            = "https://github.com/Raizlabs/RZVinyl"
  s.license             = { :type => "MIT", :file => "LICENSE" }

  s.author              = { "Nick Donaldson" => "nick.donaldson@raizlabs.com" }
  s.social_media_url    = "http://twitter.com/raizlabs"

  s.platform            = :ios, "7.0"
  s.source              = { :git => "https://github.com/Raizlabs/RZVinyl.git", :branch => "feature/ndonald2/import" }

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
    sp.xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => 'RZV_AUTOIMPORT_AVAILABLE=1'}
    # sp.dependency 'RZAutoImport', '~> 1.0'
  end
    
end
 