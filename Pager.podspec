#
#  Be sure to run `pod spec lint Pager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "Pager"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Pager."
  spec.homepage     = "http://EXAMPLE/Pager"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  spec.license      = "MIT (example)"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "touyu" => "dev.akkey0222@gmail.com" }
  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/touyu/Pager.git", :tag => "#{spec.version}" }
  s.source_files = 'Pager/**/*.{swift}'
  s.resources    = 'Pager/**/*.{xib,png}'s
end
