Pod::Spec.new do |spec|
  spec.name         = "Pager-iOS"
  spec.version      = "0.2.4"
  spec.summary      = "Elegant pager library for iOS"
  spec.homepage     = "https://github.com/touyu/Pager"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "touyu" => "dev.akkey0222@gmail.com" }
  spec.platform     = :ios, '11.0'
  spec.source       = { :git => "https://github.com/touyu/Pager.git", :tag => "#{spec.version}" }
  spec.source_files = 'Pager/**/*.{swift}'
  spec.resources    = 'Pager/**/*.{xib,png}'
  spec.swift_version = "5.0"
end
