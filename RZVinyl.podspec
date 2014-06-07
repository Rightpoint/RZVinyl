Pod::Spec.new do |s|
  s.name         = "RZVinyl"
  s.version      = "0.1.0"
  s.summary      = "Stack management, ActiveRecord utilities, and seamless importing for CoreData."

  s.description  = <<-DESC
                   Stack management, ActiveRecord utilities, and seamless importing for CoreData
                   DESC

  s.homepage     = "https://github.com/Raizlabs/RZVinyl"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Nick Donaldson" => "nick.donaldson@raizlabs.com" }
  s.social_media_url   = "http://twitter.com/raizlabs"

  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Raizlabs/RZVinyl.git", :branch => "develop" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.public_header_files = "Classes/*.h"
  s.frameworks = "Foundation", "CoreData"
  s.requires_arc = true

  s.dependency 'RZAutoImport', '~> 1.0'

end
 