require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "expo-mlkit-ocr"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  React Native module for text recognition using Google's ML Kit on Android and Apple's Vision framework on iOS
                   DESC
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]
  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => package["repository"]["url"], :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.requires_arc = true

  s.dependency "React-Core"
  
  # iOS 13+ for Vision text recognition
  s.ios.deployment_target = '13.0'
  
  s.swift_version = '5.0'
end 